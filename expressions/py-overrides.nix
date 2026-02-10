{ llvmPackages, ocp-src, pywrap-src, cadquery-src, occt, fetchFromGitHub, casadi, lib3mf }:
self: super: rec {

  pywrap = self.callPackage ./pywrap {
    inherit llvmPackages;
    # src = "${ocp-src}/pywrap";
    src = pywrap-src;
  };

  pybind11 = super.pybind11.overrideAttrs (oldAttrs: rec {
    version = "3.0.1";
    src = fetchFromGitHub {
      owner = "pybind";
      repo = "pybind11";
      tag = "v${version}";
      hash = "sha256-ZiwNGsE1FOkhnWv/1ib1akhQ4FZvrXRCDnnBZoPp6r4=";
    };
  });

  ocp = self.callPackage ./OCP {
    # llvmPackages = llvmPackages;
    src = ocp-src;
    opencascade-occt = occt;
  };

  cadquery = self.callPackage ./cadquery.nix { src = cadquery-src; };

  cq-studio = self.callPackage ./cq-studio.nix { };

  cq-kit = self.callPackage ./cq-kit { };

  cq-warehouse = self.callPackage ./cq-warehouse.nix { };

  ocpsvg = self.callPackage ./ocpsvg.nix { };

  py-lib3mf = self.callPackage ./py-lib3mf { inherit lib3mf; };

  trianglesolver = self.callPackage ./trianglesolver.nix { };

  build123d = self.callPackage ./build123d.nix { };

  yacv-server = self.callPackage ./yacv/server.nix { };
}
