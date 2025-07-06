{...}: {
  programs.niri.settings.input.touchpad.scroll-factor = 0.25;

  services.flatpak.packages = [
    {
      appId = "moe.launcher.an-anime-game-launcher";
      origin = "launcher.moe";
    }
  ];
}
