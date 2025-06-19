{
  lib,
  stdenvNoCC,
  disko,
  git,
  hello,
  makeWrapper,
  zig,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "nixinstall-zig";
  src = ./src;

  nativeBuildInputs = [
    zig
    makeWrapper
  ];

  buildInputs = [
    disko
    git
    hello
  ];

  phases = [
    "buildPhase"
    "installPhase"
    "postFixupPhase"
  ];

  buildPhase = ''
    export XDG_CACHE_HOME=$(mktemp -d)
    zig build-exe -O Debug $src/nixinstall.zig
  '';

  installPhase = ''
    install -Dm755 nixinstall $out/bin/nixinstall-zig
  '';

  postFixupPhase = ''
    wrapProgram $out/bin/nixinstall-zig \
      --set PATH ${lib.makeBinPath buildInputs}
  '';
}
