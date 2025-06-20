{
  lib,
  stdenvNoCC,
  disko,
  git,
  hello,
  makeWrapper,
  parted,
  util-linux,
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
    parted
    util-linux
  ];

  phases = [
    "buildPhase"
    "installPhase"
    "postFixupPhase"
  ];

  buildPhase = ''
    export XDG_CACHE_HOME=$(mktemp -d)
    zig build-exe -O Debug $src/nixinstall.zig
  ''; # TODO: turn off caching entirely when zig 0.15.0 comes out

  installPhase = ''
    install -Dm755 nixinstall $out/bin/nixinstall-zig
  '';

  postFixupPhase = ''
    wrapProgram $out/bin/nixinstall-zig \
      --set PATH ${lib.makeBinPath buildInputs}
  '';
}
