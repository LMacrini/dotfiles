{stdenvNoCC, autoPatchelfHook, alsa-lib, at-spi2-atk, cairo, cups, dbus, glib, gtk3, libgbm, libxkbcommon, nss, xorg, ...}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "re-lunatic-player";
  version = "1.1.0";
  src = fetchTarball {
    url = "https://github.com/Prince527GitHub/Re-Lunatic-Player/releases/download/v${finalAttrs.version}/re-lunatic-player-linux-x64-${finalAttrs.version}.tar.gz";
    sha256 = "sha256:0smicdhdfp0z9rnnvif4gia9qr250nqamwf7xc5j5pgkv0bfbcfr";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    glib
    gtk3
    libgbm
    libxkbcommon
    nss
  ] ++ (with xorg; [
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
  ]);

  installPhase = ''
    mkdir $out
    cp -r . $out/bin
  '';
})
