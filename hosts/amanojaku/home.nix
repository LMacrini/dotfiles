{ pkgs, ... }:
{
  home.packages = with pkgs; [
    teams-for-linux
  ];

  programs.niri.settings.input.touchpad.scroll-factor = 0.25;

  programs.niri.settings.outputs = {
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
}
