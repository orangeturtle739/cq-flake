# adapted from github:conda-forge/occt-feedstock which is the canonical cadquery source.
{
  stdenv
  , lib
  , fetchurl
  , fetchpatch
  , cmake
  , ninja
  , tcl
  , tk
  , libGL
  , libGLU
  , libXext
  , libXmu
  , libXi
  , vtk
  , xorg
  , freetype
  , freeimage
  , fontconfig
  , tbb_2021_11
  , rapidjson
  , glew
}:
let
  vtk_version = lib.versions.majorMinor vtk.version;
in
  stdenv.mkDerivation rec {
  pname = "opencascade-occt";
  version = "7.8.1";
  commit = "V${builtins.replaceStrings ["."] ["_"] version}";

  src = fetchurl {
    name = "occt-${commit}.tar.gz";
    url = "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${commit};sf=tgz";
    sha256 = "sha256-AGMZqTLLjXbzJFW/RSTsohAGV8sMxlUmdU/Y2oOzkk8=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [
    tcl
    tk
    libGL
    libGLU
    libXext
    libXmu
    libXi
    vtk
    xorg.libXt
    freetype
    freeimage
    fontconfig
    tbb_2021_11
    rapidjson
    glew
  ] ++ vtk.buildInputs;

  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/conda-forge/occt-feedstock/b0960c3ec14c6213fbaef5f1c5d9d8f1d8e7c1ba/recipe/patches/blobfish.patch";
      sha256 = "sha256-wbBPJLO4amPXsIk8Nn9NQv8aypq0ndv/A7OcAfnYqfk=";
    })
    (fetchpatch {
      url = "https://github.com/Open-Cascade-SAS/OCCT/commit/7236e83dcc1e7284e66dc61e612154617ef715d6.patch";
      sha256 = "sha256-NoC2mE3DG78Y0c9UWonx1vmXoU4g5XxFUT3eVXqLU60=";
    })
  ];

  # I've removed the 3RDPARTY_DIR flag, not really sure if it's needed or not
  cmakeFlags = [
    "-D BUILD_MODULE_Draw:BOOL=OFF"
    "-D USE_TBB:BOOL=ON"
    "-D BUILD_RELEASE_DISABLE_EXCEPTIONS=OFF"
    "-D USE_VTK:BOOL=ON"
    "-D 3RDPARTY_VTK_LIBRARY_DIR:FILEPATH=${vtk}/lib"
    "-D 3RDPARTY_VTK_INCLUDE_DIR:FILEPATH=${vtk}/include/vtk"
    "-D VTK_RENDERING_BACKEND:STRING=\"OpenGL2\""
    "-D USE_FREEIMAGE:BOOL=ON"
    "-D USE_RAPIDJSON:BOOL=ON"
  ];

  seperateDebugInfo = true;

  meta = with lib; {
    description = "Open CASCADE Technology, libraries for 3D modeling and numerical simulation";
    homepage = "https://www.opencascade.org/";
    license = licenses.lgpl21;  # essentially...
    # The special exception defined in the file OCCT_LGPL_EXCEPTION.txt
    # are basically about making the license a little less share-alike.
    maintainers = with maintainers; [ marcus7070 ];
    platforms = platforms.all;
  };

}
