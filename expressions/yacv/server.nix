{
  buildPythonPackage,
  fetchFromGitHub,
  fetchzip,
  # Buildtime dependencies
  poetry-core,
  # Runtime dependencies
  build123d,
  pygltflib,
  pillow,
  lib
}: let
  pname = "yacv-server";
  version = "0.9.5";
  src = fetchFromGitHub {
    owner = "yeicor-3d";
    repo = "yet-another-cad-viewer";
    rev = "v${version}";
    hash = "sha256-sdzDsyHanZlnmoQutbUvYoEN+FIQZU7pYn9FMO17t9E=";
  };
  frontend = fetchzip {
    url = "https://github.com/yeicor-3d/yet-another-cad-viewer/releases/download/v${version}/frontend.zip";
    hash = "sha256-o4dVmCDtmUxrH/KoQdZ0vUOtnCaTHKy7SzKIdHeAMGU=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    pyproject = true;

    SKIP_BUILD_FRONTEND = "1";

    build-system = [
      poetry-core
    ];

    dependencies = [
      build123d
      pygltflib
      pillow
    ];

    postPatch = ''
      cp -a ${frontend} yacv_server/frontend
      '';
  }
