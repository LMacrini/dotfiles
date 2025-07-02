{
  stdenvNoCC,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  electron,
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  glib,
  gtk3,
  libgbm,
  libxkbcommon,
  nss,
  xorg,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "re-lunatic-player";
  version = "1.1.0";
  src = fetchTarball {
    url = "https://github.com/Prince527GitHub/Re-Lunatic-Player/releases/download/v${finalAttrs.version}/re-lunatic-player-linux-x64-${finalAttrs.version}.tar.gz";
    sha256 = "sha256:0smicdhdfp0z9rnnvif4gia9qr250nqamwf7xc5j5pgkv0bfbcfr";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs =
    [
      alsa-lib
      at-spi2-atk
      cairo
      cups
      dbus
      electron
      glib
      gtk3
      libgbm
      libxkbcommon
      nss
    ]
    ++ (with xorg; [
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
    ]);

  desktopItems = makeDesktopItem {
    name = "re-lunatic-player";
    desktopName = "Re:Lunatic Player";
    exec = "re-lunatic-player";
    startupWMClass = "Re:Lunatic Player";
    genericName = "Radio Player";
    keywords = [
      "radio"
      "touhou"
      "lunatic"
      "player"
      "music"
    ];
    categories = [
      "Audio"
      "AudioVideo"
    ];
  };

  installPhase = ''
    mkdir $out
    cp -r . $out/opt

    makeWrapper ${electron}/bin/electron $out/bin/re-lunatic-player \
      --add-flags $out/opt/resources/app.asar

    runHook postInstall
  '';
})
