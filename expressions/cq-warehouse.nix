{ lib, python, buildPythonPackage, fetchFromGitHub, cadquery, setuptools }:
buildPythonPackage rec {
  pname = "cq-warehouse";
  rev = "daa46507ecc429c0e2dce11d9d5ffd09b12a42af";
  version = "git+daa4650";
  src = fetchFromGitHub {
    owner = "gumyr";
    repo = "cq_warehouse";
    inherit rev;
    sha256 = lib.fakeHash;
  };

  build-system = [ setuptools ];
  format = "pyproject";

  propagatedBuildInputs = [ cadquery ];

  checkPhase = ''
    ${python.interpreter} -m unittest tests
  '';
}
