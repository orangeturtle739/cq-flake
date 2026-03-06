{ buildPythonPackage, fetchPypi,
# Buildtime dependencies
git, pytestCheckHook, setuptools-scm,
# Runtime dependencies
ocp, svgpathtools, svgelements, lib }:
let
  pname = "ocpsvg";
  version = "0.6.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8I2kNHzJDs01ZTlem9pXRtRquKr9aiaBuwOpwyG1QDk=";
  };
in buildPythonPackage {
  inherit src pname version;
  pyproject = true;

  patchPhase = ''
    substituteInPlace pyproject.toml \
      --replace "cadquery-ocp" "ocp"
  '';

  build-system = [ setuptools-scm git ];

  nativeCheckInputs = [ pytestCheckHook ];

  dependencies = [ ocp svgpathtools svgelements ];

}

