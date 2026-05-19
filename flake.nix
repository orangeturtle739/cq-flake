{
  description = "CQ-editor and CadQuery";

  nixConfig = { extra-experimental-features = "nix-command flakes"; };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cadquery-src = {
      url = "github:CadQuery/cadquery";
      flake = false;
    };
    ocp-src = {
      url =
        "git+https://github.com/cadquery/ocp?submodules=1&rev=939afdaee92f31008e5380ecaef929458d86963d";
      flake = false;
    };
    pywrap-src = {
      # https://github.com/CadQuery/pywrap/commits/arg-fix/
      url =
        "git+https://github.com/CadQuery/pywrap?rev=77e20408ceb31a77c9b7e45961b1e2873df150a1";
      flake = false;
    };
    occt-src = {
      # https://github.com/CadQuery/OCP/blob/939afdaee92f31008e5380ecaef929458d86963d/opencascade/Standard_Version.hxx#L48
      url =
        "git+https://github.com/Open-Cascade-SAS/OCCT.git?rev=a509566a2833b2be0a1ea550905908d2df4f8b21";
      flake = false;
    };
    /* vtk-src = {
       url = "git+https://gitlab.kitware.com/vtk/vtk.git?rev=";
       flake = false;
       };
    */
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      systems = [ "aarch64-linux" "x86_64-linux" ];
      overlay = final: prev: {
        opencascade-occt = prev.opencascade-occt.overrideAttrs (oldAttrs: rec {
          version = "8.0.0-rc3";
          commit =
            "V${builtins.replaceStrings [ "." "-" ] [ "_" "_" ] version}";
          src = inputs.occt-src;
          buildInputs = oldAttrs.buildInputs ++ [ final.expat ];
          patches = [ ./0001-Include-TDF_Label.hxx.patch ];
        });
        vtk_9_5 = prev.vtk_9_5.overrideAttrs (oldAttrs: rec {
          # src = inputs.vtk-src;
          patches = oldAttrs.patches ++ [ ./0001-Migrate-to-OCCT-V8.patch ];
        });
        # lib3mf = final.callPackage ./expressions/lib3mf { };
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (import expressions/py-overrides.nix {
            inherit (inputs) ocp-src cadquery-src;
            pywrap-src = "${inputs.ocp-src}/pywrap";
            inherit (final) fetchFromGitHub;
            llvmPackages = final.llvmPackages_21;
            occt = final.opencascade-occt;
            casadi = prev.casadi.override { pythonSupport = true; };
          })
        ];
        yacv-env = final.python3.withPackages (pkgs: [ pkgs.yacv-server ]);
        freeimage = prev.freeimage.overrideAttrs (oldAttrs: rec {
          meta = (removeAttrs oldAttrs.meta [ "knownVulnerabilities" ]);
        });
      };
    in {
      overlays.default = overlay;
    } // flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
          config.permittedInsecurePackages =
            [ "freeimage-3.18.0-unstable-2024-04-18" ];
        };
      in rec {
        packages = {
          inherit (pkgs.python3.pkgs)
            cadquery cq-kit cq-warehouse build123d cq-studio;
          inherit (pkgs) python3;
          python = pkgs.python3;
          lol = pkgs.python3.withPackages (ps: [ ps.cadquery ]);
          default = packages.cq-studio;
        };

        legacyPackages = pkgs;

        apps.default = flake-utils.lib.mkApp { drv = packages.default; };
      });
}
