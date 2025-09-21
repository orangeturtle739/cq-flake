{ lib, buildPythonPackage, pythonOlder, src, llvmPackages, libclang, pybind11
, joblib, toml, cmake, ninja, click, jinja2, logzero, pandas, path, pyparsing
, schema, tqdm, toposort, python, fetchpatch, setuptools }:

let libclang_new = libclang.override { inherit llvmPackages; };

in buildPythonPackage rec {
  version = "git-" + builtins.substring 0 7 src.rev;
  pname = "pywrap";
  inherit src;

  pyproject = true;
  build-system = [ setuptools ];

  propagatedBuildInputs = [
    libclang_new
    pybind11
    joblib
    toml
    cmake
    ninja
    click
    jinja2
    logzero
    pandas
    path
    pyparsing
    schema
    tqdm
    toposort
  ];

  dontUseCmakeConfigure = true;

  # do I need this at all?
  postPatch = ''
    substituteInPlace bindgen/CMakeLists.j2 --replace '$ENV{CONDA_PREFIX}/bin/python' ${python}
  '';

  pythonImportCheck = [ "bindgen" ];

  makeWrapperArgs =
    [ ''--add-flags "-l ${llvmPackages.libclang.lib}/lib/libclang.so"'' ];

  meta = with lib; {
    description = "C++ binding generator based on libclang and pybind11";
    homepage = "https://github.com/CadQuery/pywrap/";
    license = licenses.asl20;
    maintainers = with maintainers; [ marcus7070 ];
  };
}
