{
  stdenvNoCC,
  inputs,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wam-icons";
  version = "0-unstable-07-09";

  src = ./.;

  # sourceRoot = "${finalAttrs.src.name}/icons";

  strictDeps = true;

  installPhase = ''
    mkdir $out
    cp -r $src $out/share
  '';

  enableParallelBuilding = true;
})
