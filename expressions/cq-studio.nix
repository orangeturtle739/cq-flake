{
  buildPythonPackage,
  fetchFromGitHub,
  # Buildtime dependencies
  poetry-core,
  # Runtime dependencies
  cadquery,
  build123d,
  click,
  yacv-server,
  fetchzip,
  lib
}: let
  pname = "cq-studio";
  version = "0.8.1";
  src = fetchFromGitHub {
    owner = "ccazabon";
    repo = pname;
    rev = "release/${version}";
    hash = "sha256-cl1xS6+FFiVNnJngenqZWNw9kbcF9/S8XEHCqT2DlUs=";
  };
in
  buildPythonPackage {
    inherit src pname version;
    pyproject = true;

    build-system = [
      poetry-core
    ];

    dependencies = [
      cadquery
      build123d
      click
      yacv-server
    ];
  }
