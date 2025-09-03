{ lib, stdenv, src, ocp-stubs, buildPythonPackage, setuptools, pythonOlder
, cmake, ninja, glibc, opencascade-occt-vtk, fmt, libglvnd, libx11, xorgproto
, python, writeTextFile, pywrap, vtk-occt-vtk, rapidjson, lief, path
, llvmPackages, pybind11 }:
let
  # We need to use an unmodified version number for the dist-utils version so
  # that the version check in cadquery works
  # remember to change version number in dump_symbols.py as well
  base-version = "7.9.3.1";
  version = "v${base-version}-git-${src.shortRev}";

  vtk_main_version = lib.versions.majorMinor vtk-occt-vtk.version;

  ocp-dump-symbols = stdenv.mkDerivation rec {
    pname = "ocp-dump-symbols";
    inherit version src;

    nativeBuildInputs = [ lief path opencascade-occt-vtk ];

    phases = [ "unpackPhase" "buildPhase" "installPhase" "installCheckPhase" ];

    dumpSymbols = ./dump_symbols.py;

    buildPhase = ''
      python $dumpSymbols ${opencascade-occt-vtk}
    '';

    installPhase = ''
      mkdir -p $out
      cp ./symbols_mangled_linux.dat $out
      echo "Checking we did not install an empty file"
      [ -s $out/symbols_mangled_linux.dat ]
    '';

  };

  python-with-pywrap-packages = python.withPackages (ps:
    with ps; [
      pybind11
      joblib
      toml
      click
      jinja2
      logzero
      pandas
      path
      pyparsing
      schema
      tqdm
      toposort
      lief
      (libclang.override { inherit llvmPackages; })
    ]);

  # intermediate step, do pybind, cmake in the next step
  ocp-pybound = stdenv.mkDerivation rec {
    pname = "pybound-ocp";
    inherit version src;

    phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    buildPhase = ''
      cp -a ${ocp-stubs} OCP
    '';

    installPhase = ''
      mkdir -p $out
      cp -r ./* $out/
    '';
  };

  ocp-result = stdenv.mkDerivation rec {
    pname = "ocp-result";
    inherit version;

    src = ocp-pybound;

    disabled = pythonOlder "3.6";

    # do not put glibc.dev in here https://discourse.nixos.org/t/how-to-get-this-basic-c-build-to-work-in-a-nix-shell/12262/3
    # https://github.com/NixOS/nixpkgs/pull/28748
    nativeBuildInputs = [ cmake ninja pywrap pybind11 fmt python rapidjson ];

    buildInputs = [ libglvnd.dev libx11.dev xorgproto vtk-occt-vtk ]
      ++ opencascade-occt-vtk.buildInputs ++ vtk-occt-vtk.buildInputs;

    preConfigure = ''
      export CMAKE_PREFIX_PATH=${pybind11}/share/cmake/pybind11:$CMAKE_PREFIX_PATH
      export PYBIND11_USE_CMAKE=1
      export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:${glibc.dev}/include
      echo "CMAKE_INCLUDE_PATH is:"
      echo $CMAKE_INCLUDE_PATH
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-deprecated-declarations"
      echo "NIX_CFLAGS_COMPILE: $NIX_CFLAGS_COMPILE"
      rm -f CMakeCache.txt
    '';

    propagatedBuildInputs = [ opencascade-occt-vtk ];

    cmakeFlags = [
      "-S ../OCP"
      "-DPYTHON_EXECUTABLE=${python}/bin/python"
      "-DOpenCASCADE_INCLUDE_DIR=${src}/opencascade"
      "-DVTK_DIR=${vtk-occt-vtk}/lib/cmake/vtk/"
      "-Wno-dev"
    ];

    seperateDebugInfo = true;

    checkPhase = ''
      pushd .
      cd build
      python -c "import OCP.gp"
      popd
    '';

    installPhase = ''
      mkdir $out
      cp ./*.so $out/
    '';
  };

  setuppy = writeTextFile {
    name = "setup.py";
    text = ''
      from setuptools import setup
      from setuptools.command.build_py import build_py
      from os import getenv


      class BuildPyNoBuild(build_py):
          def build_packages(self):
              pass


      setup(
          name='OCP',
          version=getenv("SETUPTOOLS_SCM_PRETEND_VERSION"),
          description="Python wrapper for OCCT",
          license="Apache License 2.0",
          packages=[""],
          package_dir={"": "."},
          package_data={
              "": ["OCP.${python.implementation}-${python.sourceVersion.major}${python.sourceVersion.minor}-${stdenv.system}-gnu.so"]
          },
          cmdclass = {"build_py": BuildPyNoBuild}
      )
    '';
  };

in buildPythonPackage {
  pname = "OCP";
  inherit version;
  src = ocp-result;

  pyproject = true;
  build-system = [ setuptools ];

  SETUPTOOLS_SCM_PRETEND_VERSION = "${base-version}";

  prePatch = ''
    cp ${setuppy} ./setup.py
  '';

  propagatedBuildInputs = [ opencascade-occt-vtk ];

  pythonImportsCheck = [ "OCP" "OCP.gp" ];

  meta = with lib; {
    description =
      "Python wrapper for Opencascade Technology ${version} generated using pywrap";
    homepage = "https://github.com/CadQuery/OCP";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
