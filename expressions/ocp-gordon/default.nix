{ buildPythonPackage, fetchFromGitHub,
# Buildtime dependencies
git, pytestCheckHook, setuptools-scm,
# Runtime dependencies
numpy, ocp, scipy, lib }:
let
  pname = "ocp_gordon";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "gongfan99";
    repo = pname;
    rev = "81a573ea8950bab0e11a416dc5426ebfcbe64cea";
    deepClone = true;
    hash = "sha256-mONaUnNWCX8Fl5wEa+himWIZX8jz/v7X0rAhfxV+MYc=";
  };
in buildPythonPackage {
  inherit src pname version;
  format = "pyproject";

  patches = [ ./0001-do-not-restrict-ocp-version.patch ];

  nativeBuildInputs = [ git pytestCheckHook setuptools-scm ];

  propagatedBuildInputs = [
    numpy
    scipy
    ocp
  ];
}
