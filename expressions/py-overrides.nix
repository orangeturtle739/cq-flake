{ llvmPackages, ocp-src, ocp-stubs, cadquery-src, casadi }:
self: super: rec {
  pywrap = self.callPackage ./pywrap {
    inherit llvmPackages;
    src = "${ocp-src}/pywrap";
  };

  ocp = self.callPackage ./OCP {
    inherit ocp-stubs;
    llvmPackages = llvmPackages;
    src = ocp-src;
  };

  cadquery = self.callPackage ./cadquery { src = cadquery-src; };

  cq-studio = self.callPackage ./cq-studio.nix { };

  cq-kit = self.callPackage ./cq-kit { };

  cq-docs = self.callPackage ./cq-docs.nix { };
  cq-warehouse = self.callPackage ./cq-warehouse.nix { };

  ocpsvg = self.callPackage ./ocpsvg { };

  py-lib3mf = self.callPackage ./py-lib3mf { };

  trianglesolver = self.callPackage ./trianglesolver.nix { };
  runtype = self.callPackage ./runtype.nix { };

  build123d = self.callPackage ./build123d { };
  ocp-gordon = self.callPackage ./ocp-gordon { };

  yacv-server = self.callPackage ./yacv/server.nix { };
}
