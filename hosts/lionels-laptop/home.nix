{pkgs, ...}: {
  programs.niri.settings.input.touchpad.scroll-factor = 0.25;

  services.flatpak.packages = [
    "org.gnome.Boxes"
  ];

  programs.niri.settings.outputs = {
    eDP-1 = {
      enable = true;
      focus-at-startup = true;
      position = {
        x = 0;
        y = 0;
      };
      scale = 1;
    };

    DP-3 = {
      enable = true;
      focus-at-startup = false;
      position = {
        x = 0;
        y = -1200;
      };
      scale = 1;
    };
  };
}
