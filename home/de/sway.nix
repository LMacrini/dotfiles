{ lib, cfg, pkgs, ... }: lib.mkIf cfg.de.sway.enable {
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty"; 
      startup = [
        {command = "floorp";}
      ];
    };
  };

  home.packages = with pkgs; [
    alacritty
  ];
}
