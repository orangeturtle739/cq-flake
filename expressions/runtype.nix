{ buildPythonPackage, fetchPypi, lib, poetry-core}:
let
  pname = "runtype";
  version = "0.5.3";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zK7AXHT40hM0K5/CXjBFYNEUvE1y7BF2Oc0eevnF2x8=";
  };
in buildPythonPackage {
  inherit src pname version;
  format = "pyproject";

  build-system = [ poetry-core ];
}
