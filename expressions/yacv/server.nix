{ buildPythonPackage, fetchFromGitHub, fetchzip,
# Buildtime dependencies
poetry-core,
# Runtime dependencies
build123d, pygltflib, pillow, lib }:
let
  pname = "yacv-server";
  version = "0.10.11";
  src = fetchFromGitHub {
    owner = "yeicor-3d";
    repo = "yet-another-cad-viewer";
    rev = "v${version}";
    hash = "sha256-u9StuQqfyf3NCSbdh4obDcLJbjS9wfCNNpfd8nuaK/E=";
  };
  frontend = fetchzip {
    url =
      "https://github.com/yeicor-3d/yet-another-cad-viewer/releases/download/v${version}/frontend.zip";
    hash = "sha256-yogt3MQ2lNR5bG1USF9teRbH+Zn7Hyq7ptTtTtBHKWI=";
  };
in buildPythonPackage {
  inherit src pname version;
  pyproject = true;

  SKIP_BUILD_FRONTEND = "1";

  patches = [ ./0001-do-not-restrict-versions.patch ];

  build-system = [ poetry-core ];

  dependencies = [ build123d pygltflib pillow ];

  postPatch = ''
    cp -a ${frontend} yacv_server/frontend
  '';
}
