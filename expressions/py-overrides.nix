{ llvmPackages, ocp-src, pywrap-src, cadquery-src, occt, fetchFromGitHub, casadi
}:
self: super: rec {

  pywrap = self.callPackage ./pywrap {
    inherit llvmPackages;
    # src = "${ocp-src}/pywrap";
    src = pywrap-src;
  };

  ocp = self.callPackage ./OCP {
    # llvmPackages = llvmPackages;
    src = ocp-src;
    opencascade-occt = occt;
    /*
    pybind11 = super.pybind11.overrideAttrs (oldAttrs: rec {
      version = "3.0.1-beta";
      src = fetchFromGitHub {
        owner = "pybind";
        repo = "pybind11";
        rev = "3ae5a173c54ab64339ad4a6c57557896b8bad6f9";
        hash = "sha256-ANzdW4ffT//3OeaYBOXQt04Ib6B4doN+BmWgtWXTZ1s=";
      };
    });
    */
  };

  cadquery = self.callPackage ./cadquery { src = cadquery-src; };

  cq-studio = self.callPackage ./cq-studio.nix { };

  cq-kit = self.callPackage ./cq-kit { };

  cq-warehouse = self.callPackage ./cq-warehouse.nix { };

  ocpsvg = self.callPackage ./ocpsvg { };

  py-lib3mf = self.callPackage ./py-lib3mf { };

  trianglesolver = self.callPackage ./trianglesolver.nix { };

  build123d = self.callPackage ./build123d { };
  ocp-gordon = self.callPackage ./ocp-gordon { };

  yacv-server = self.callPackage ./yacv/server.nix { };
}
