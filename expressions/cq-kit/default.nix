{ lib, buildPythonPackage, fetchFromGitHub, cadquery, pytestCheckHook, rich
, setuptools }:
buildPythonPackage rec {
  pname = "cq-kit";
  rev = "820c62d42c1d7dcb97692ab7ed67d2fea7dc1e2a";
  version = "0.5.9";
  src = fetchFromGitHub {
    owner = "michaelgale";
    repo = pname;
    inherit rev;
    sha256 = lib.fakeHash;
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace cqkit/cq_discrete.py \
      --replace-fail "tri.Value" "tri"
  '';

  pyproject = true;
  build-system = [ setuptools ];

  propagatedBuildInputs = [ cadquery ];

  checkInputs = [ pytestCheckHook rich ];
}
