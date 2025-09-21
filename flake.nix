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
      url = "github:cadquery/ocp/7.8.1.2";
      flake = false;
    };
    ocp-stubs-src = {
      url = "github:cadquery/ocp-stubs";
      flake = false;
    };
    pywrap-src = {
      url = "github:CadQuery/pywrap";
      flake = false;
    };
    pybind11-stubgen-src = {
      url = "github:CadQuery/pybind11-stubgen";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      systems = [ "aarch64-linux" "x86_64-linux" ];
      overlay = final: prev: {
        lib3mf = final.callPackage ./expressions/lib3mf { };
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (import expressions/py-overrides.nix {
            inherit (inputs)
              pywrap-src ocp-src ocp-stubs-src cadquery-src
              pybind11-stubgen-src;
            inherit (final) fetchFromGitHub;
            llvmPackages = final.llvmPackages_20;
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
      in rec {
        packages = {
          inherit (pkgs.python3.pkgs)
            cadquery cq-kit cq-warehouse build123d cq-studio;
          inherit (pkgs) python3 yacv-frontend;
          python = pkgs.python3;
        };

        legacyPackages = pkgs;

        defaultPackage = packages.cq-studio;
        apps.default = flake-utils.lib.mkApp { drv = defaultPackage; };
      });
}
