{ buildPythonPackage, fetchFromGitHub,
# Buildtime dependencies
git, pytestCheckHook, setuptools-scm,
# Runtime dependencies
anytree, ezdxf, ipython, numpy, ocp, ocpsvg, lib3mf, py-lib3mf, scipy
, svgpathtools, sympy, trianglesolver, vtk, lib }:
let
  pname = "build123d";
  version = "0.1.0-beta";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = pname;
    rev = "cb155f79d18f8247eb8e951617d0a3056be0ceec";
    deepClone = true;
    hash = "sha256-IoWAtFGO9ie550ugpUsUDjuwxXOEk/o6RhTn3XAaQdU=";
  };
in buildPythonPackage {
  inherit src pname version;
  format = "pyproject";

  patchPhase = ''
    substituteInPlace pyproject.toml \
      --replace "cadquery-ocp" "ocp"
  '';

  nativeBuildInputs = [ git pytestCheckHook setuptools-scm ];

  propagatedBuildInputs = [
    anytree
    ezdxf
    ipython
    numpy
    ocp
    ocpsvg
    py-lib3mf
    scipy
    svgpathtools
    sympy
    trianglesolver
    vtk
  ];

  disabledTests = [
    # These attempt to access the network
    "test_assembly_with_oriented_parts"
    "test_move_single_object"
    "test_single_label_color"
    "test_single_object"
  ];

}
