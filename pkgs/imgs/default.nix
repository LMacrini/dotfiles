{ stdenvNoCC }:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "wam-icons";
  src = ./.;

  strictDeps = true;

  installPhase = ''
    mkdir $out
    cp -r $src $out/share
  '';

  enableParallelBuilding = true;
})
