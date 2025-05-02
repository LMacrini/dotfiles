{
  pkgs,
  lib,
  cfg,
  ...
}:
lib.mkIf cfg.de.sway.enable {
  home.packages = with pkgs; [
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      terminal = "kitty";

      modifier = "Mod4"; # Mod4 is super, check man 5 sway for others

      output = builtins.mapAttrs (_: x:
        x
        // {
          bg = "${../home/.config/background.jpg} fill";
        })
      cfg.de.sway.output;
    };
  };
}
