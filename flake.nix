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
        "git+https://github.com/cadquery/ocp?submodules=1&rev=01055e099a3b1a34da38bb1f5457f06a2d4c7a18";
      flake = false;
    };
    pywrap-src = {
      url = "git+https://github.com/CadQuery/pywrap?rev=9c9ca5b8aa0d9a6687394897815a682b8c319fb0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      systems = [ "aarch64-linux" "x86_64-linux" ];
      overlay = final: prev: {
        /* opencascade-occt = prev.opencascade-occt.overrideAttrs (oldAttrs: rec {
           version = "7.9.0";
           commit = "V${builtins.replaceStrings [ "." ] [ "_" ] version}";
           src = final.fetchurl {
             name = "occt-${commit}.tar.gz";
             url =
               "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${commit};sf=tgz";
             hash = "sha256-wZJKLDn0FH89HpILSm2eE5L5waNY3XzaopHemppmzWI=";
           };
           patches = [ ];
           });
        */
        # lib3mf = final.callPackage ./expressions/lib3mf { };
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (import expressions/py-overrides.nix {
            inherit (inputs) ocp-src pywrap-src cadquery-src;
            inherit (final) fetchFromGitHub;
            llvmPackages = final.llvmPackages_21;
            occt = final.opencascade-occt;
            casadi = prev.casadi.override { pythonSupport = true; };
            lib3mf = final.lib3mf;
          })
        ];
        yacv-env = final.python3.withPackages (pkgs: [ pkgs.yacv-server ]);
        yacv-frontend = final.callPackage ./expressions/yacv/frontend.nix { };
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
        flakePackages = {
          inherit (pkgs.python3.pkgs)
            cadquery cq-kit cq-warehouse build123d cq-studio;
          inherit (pkgs) python3 yacv-frontend;
          python = pkgs.python3;
        };
      in rec {
        packages = {
          inherit (pkgs.python3.pkgs)
            cadquery cq-kit cq-warehouse build123d cq-studio;
          inherit (pkgs) python3 yacv-frontend;
          python = pkgs.python3;
          default = packages.cq-studio;
        };

        legacyPackages = pkgs;

        apps.default = flake-utils.lib.mkApp { drv = packages.default; };
      });
}
