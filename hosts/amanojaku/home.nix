{
  pkgs,
  lib,
  cfg,
  ...
}:
{
  home.packages = with pkgs; [
    teams-for-linux
  ];

  programs.niri.settings = lib.mkIf (cfg.de.de == "niri") {
    input.touchpad.scroll-factor = 0.25;

    outputs = {
      eDP-1 = {
        enable = true;
        focus-at-startup = true;
        position = {
          x = 0;
          y = 0;
        };
        scale = 2;
      };
    };
  };
}
