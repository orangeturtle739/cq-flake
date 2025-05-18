{
  buildPythonPackage,
  fetchurl,
  # Buildtime dependencies
  setuptools,
  lib3mf,
  unzip,
  lib
}:
let
  pname = "py-lib3mf";
  version = "2.4.1";
  src = fetchurl {
    url = "https://github.com/3MFConsortium/lib3mf/releases/download/v${version}/lib3mf-${version}-py3-none-manylinux2014_x86_64.whl";
    hash = "sha256-VJliSH1PP1OVpQmOLK1zDAWCxVxDwIsktD56YwZINjc=";
  };
in
buildPythonPackage {
  inherit src pname version;
  format = "pyproject";
  unpackCmd = "unzip $curSrc -d src";

  nativeBuildInputs = [ unzip setuptools ];

  patchPhase = ''
    pwd
    cp ${lib3mf}/lib/lib3mf.so.${version}.0 lib3mf/lib3mf.so
    cp ${./pyproject.toml} pyproject.toml
    cp ${./MANIFEST.in} MANIFEST.in
  '';
}

