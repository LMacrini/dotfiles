{pkgs, ...}: {
  programs.niri.settings.outputs = {
    "DP-1" = {
      enable = true;
      focus-at-startup = true;
      position = {
        x = 0;
        y = 0;
      };
      scale = 1;
    };

    "HDMI-A-2" = {
      enable = true;
      mode = {
        width = 1920;
        height = 1080;
        refresh = 144.001;
      };
      position = {
        x = 2560;
        y = 180;
      };
      scale = 1;
    };
  };

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
    zoom-us
    unityhub
  ];

  services.flatpak.packages = [
    "app.twintaillauncher.ttl"
  ];
}
