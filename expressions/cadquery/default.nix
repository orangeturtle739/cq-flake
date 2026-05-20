{ lib, buildPythonPackage, setuptools, setuptools-scm, isPy3k, pythonOlder
, fetchFromGitHub, makeFontsConf, freefont_ttf, pytestCheckHook, pytest-xdist
, ocp, casadi, pythonPackages, ezdxf, ipython, src, nptyping, typish, vtk, nlopt
, multimethod, docutils, path }:

buildPythonPackage rec {
  pname = "cadquery";
  version = if (builtins.hasAttr "rev" src) then
    (builtins.substring 0 7 src.rev)
  else
    "local-dev";
  inherit src;

  pyproject = true;
  build-system = [ setuptools ];
  patches = [ ./0001-do-not-restrict-ocp-version.patch ];

  SETUPTOOLS_SCM_PRETEND_VERSION = "${version}";

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs =
    [ ocp ezdxf casadi ipython nptyping typish vtk nlopt multimethod ];

  # If the user wants extra fonts, probably have to add them here
  FONTCONFIG_FILE = makeFontsConf { fontDirectories = [ freefont_ttf ]; };

  disabled = !isPy3k;

  checkInputs = [ pytestCheckHook pytest-xdist docutils path ];

  pytestFlags = [
    "-W ignore::FutureWarning"
    "-n $NIX_BUILD_CORES"
    "-k 'not example'"
    "-k 'not testTextAlignment'"
  ];

  meta = with lib; {
    description =
      "Parametric scripting language for creating and traversing CAD models";
    homepage = "https://github.com/CadQuery/cadquery";
    license = licenses.asl20;
    maintainers = with maintainers; [ costrouc marcus7070 ];
  };
}
