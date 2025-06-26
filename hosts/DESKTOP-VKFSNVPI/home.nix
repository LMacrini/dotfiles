{pkgs, ...}: {
  xdg.desktopEntries = {
    iwtc = {
      name = "I WANT TO CRAFT";
      startupNotify = false;
      terminal = false;
      exec = "${pkgs.fjordlauncher}/bin/fjordlauncher -l \"I WANT TO CRAFT\" -s mc.serversmp.xyz:25565 -a Wam25";
      icon = "${pkgs.fjordlauncher}/share/icons/hicolor/scalable/apps/org.unmojang.FjordLauncher.svg";
    };

    iwtcseija = {
      name = "I WANT TO CRAFT (ely account)";
      startupNotify = false;
      terminal = false;
      exec = "${pkgs.fjordlauncher}/bin/fjordlauncher -l \"I WANT TO CRAFT 2\" -s mc.serversmp.xyz:25565 -a seija_";
      icon = "${pkgs.fjordlauncher}/share/icons/hicolor/scalable/apps/org.unmojang.FjordLauncher.svg";
    };
  };

  home.packages = with pkgs; [
    dconf-editor
    unityhub
  ];

  services.flatpak.packages = [
    "org.gnome.Boxes"
    {
      appId = "moe.launcher.an-anime-game-launcher";
      origin = "launcher.moe";
    }
  ];

  programs = {
    cava.settings.general.framerate = 144;
  };
}
