{
  fetchzip,
  writeShellScriptBin,
  python3,
}:
let
  frontend = fetchzip {
    url = "https://github.com/yeicor-3d/yet-another-cad-viewer/releases/download/v0.9.2/frontend.zip";
    hash = "sha256-JcMJlwx/wGul1QVXHD51pK2BFVz/kgqcLLanEmHwop0=";
  };
in
  writeShellScriptBin "yacv-frontend" "${python3}/bin/python -m http.server --directory ${frontend}"
