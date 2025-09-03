{ buildPythonPackage, fetchurl, setuptools, lib3mf, unzip, lib }:
let
  pname = "py-lib3mf";
  version = "2.5.0";
  src = fetchurl {
    url =
      "https://github.com/3MFConsortium/lib3mf/releases/download/v${version}/lib3mf-${version}-py3-none-manylinux2014_x86_64.whl";
    hash = "sha256-tMAAM8R8/qyTt9qgaftG6N6kOR1VIrec1un2r3XjMBM=";
  };
in buildPythonPackage {
  inherit src pname version;
  format = "pyproject";
  unpackCmd = "unzip $curSrc -d src";

  nativeBuildInputs = [ unzip setuptools ];

  patchPhase = ''
    cp ${lib3mf}/lib/lib3mf.so.${version}.0 lib3mf/lib3mf.so
    substitute ${
      ./pyproject.toml
    } pyproject.toml --subst-var-by VERSION ${version}
    cp ${./MANIFEST.in} MANIFEST.in
  '';
}

