{
  description = "CQ-editor and CadQuery";

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
    ocp-stubs = {
      url =
        "https://github.com/CadQuery/OCP/releases/download/7.9.3.1/OCP_src_stubs_Linux.zip";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      systems = [ "aarch64-linux" "x86_64-linux" ];
      overlay = final: prev: rec {
        opencascade-occt-vtk = prev.opencascade-occt.override {
          withVtk = true;
          vtk = prev.vtk;
        };
        vtk-occt-vtk = prev.vtk.override {
          opencascade-occt = opencascade-occt-vtk;
          pythonSupport = true;
        };
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (import expressions/py-overrides.nix {
            inherit (inputs) ocp-src ocp-stubs cadquery-src;
            llvmPackages = final.llvmPackages_21;
            casadi = prev.casadi.override { pythonSupport = true; };
          })
        ];
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
          default = packages.cq-studio;
        };
        legacyPackages = pkgs;
        apps.default = flake-utils.lib.mkApp { drv = packages.default; };
      });
}
