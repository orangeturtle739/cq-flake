{ buildPythonPackage, fetchFromGitHub, fetchzip,
# Buildtime dependencies
poetry-core,
# Runtime dependencies
build123d, pygltflib, pillow, hatchling, lib }:
let
  pname = "yacv-server";
  version = "0.11.1";
  src = fetchFromGitHub {
    owner = "yeicor-3d";
    repo = "yet-another-cad-viewer";
    rev = "v${version}";
    hash = "sha256-BNo5jEZmq4Dt4NOU7L358IRZKekuRmv4ZUAhtdJ1dWo=";
  };
  frontend = fetchzip {
    url =
      "https://github.com/yeicor-3d/yet-another-cad-viewer/releases/download/v${version}/frontend.zip";
    hash = "sha256-vOtNd61xu8Q5i/HqBh+3e3EFzAFa793w8LjYc+C4Za4=";
  };
in buildPythonPackage {
  inherit src pname version;
  pyproject = true;

  patches = [ ./0001-do-not-restrict-123d-version.patch ];

  SKIP_BUILD_FRONTEND = "1";

  build-system = [ poetry-core ];

  dependencies = [ build123d pygltflib pillow hatchling ];

  postPatch = ''
    cp -a ${frontend} yacv_server/frontend
  '';
}
