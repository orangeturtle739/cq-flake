{ buildPythonPackage, fetchFromGitHub,
# Buildtime dependencies
pytestCheckHook, setuptools-scm,
# Runtime dependencies
anytree, ezdxf, ipython, numpy, ocp, ocpsvg, lib3mf, py-lib3mf, scipy
, svgpathtools, sympy, trianglesolver, vtk-occt-vtk, webcolors, ocp-gordon, lib
}:
let
  pname = "build123d";
  version = "0.10.0-beta";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = pname;
    rev = "934ebe661235f3ab17c3a64b1b542171cc8dcc70";
    hash = "sha256-t8lqrUZ2Q98iU3q4sJACDD3vX8CUHMxbRn943s8xmgY=";
  };
in buildPythonPackage {
  inherit src pname version;
  format = "pyproject";

  patches = [ ./0001-do-not-restrict-ocp-version.patch ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  nativeBuildInputs = [ pytestCheckHook setuptools-scm ];

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
    vtk-occt-vtk
    webcolors
    ocp-gordon
  ];

  disabledTests = [
    # These attempt to access the network
    "test_assembly_with_oriented_parts"
    "test_move_single_object"
    "test_single_label_color"
    "test_single_object"
  ];

}
