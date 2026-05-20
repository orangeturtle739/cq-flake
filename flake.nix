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
        "git+https://github.com/cadquery/ocp?submodules=1&rev=d69b064a3a604ebf245b1f3b14fb54c835a3a571";
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
        /* opencascade-occt = prev.opencascade-occt.overrideAttrs (oldAttrs: rec {
           version = "7.9.3";
           commit =
             "V${builtins.replaceStrings [ "." "-" ] [ "_" "_" ] version}";
           src = inputs.occt-src;
           buildInputs = oldAttrs.buildInputs ++ [ final.expat ];
           patches = [ ./0001-Include-TDF_Label.hxx.patch ];
           });
        */
        /* vtk_9_5 = prev.vtk_9_5.overrideAttrs (oldAttrs: rec {
           # src = inputs.vtk-src;
           patches = oldAttrs.patches ++ [ ./0001-Migrate-to-OCCT-V8.patch ];
           });
        */
        # lib3mf = final.callPackage ./expressions/lib3mf { };
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (import expressions/py-overrides.nix {
            inherit (inputs) ocp-src cadquery-src;
            pywrap-src = "${inputs.ocp-src}/pywrap";
            inherit (final) fetchFromGitHub;
            llvmPackages = final.llvmPackages_21;
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
