{
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
  git,
  pytestCheckHook,
  setuptools-scm,
  # Runtime dependencies
  anytree,
  ezdxf,
  ipython,
  numpy,
  ocp,
  ocpsvg,
  lib3mf,
  py-lib3mf,
  scipy,
  svgpathtools,
  sympy,
  trianglesolver,
  vtk,
}: let
  pname = "build123d";
  version = "0.9.2";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = pname;
    rev = "67115111e2139540fff5560fceaf7ade9a1c3ac8";
    deepClone = true;
    hash = "sha256-bnygtEHgn7sgBU+By1kALMowrTxMl72Vt6aZDSs7cGI=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    format = "pyproject";

    patchPhase = ''
      substituteInPlace pyproject.toml \
        --replace "cadquery-ocp" "ocp"
    '';

    nativeBuildInputs = [
      git
      pytestCheckHook
      setuptools-scm
    ];

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
