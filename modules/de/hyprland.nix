{pkgs, lib, config, ...}: {
  options = {
    de.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf config.de.hyprland.enable {
    programs.hyprland = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      kitty
      rofi-wayland
      swaynotificationcenter
      hyprpaper
      waybar
    ];
  };
}
