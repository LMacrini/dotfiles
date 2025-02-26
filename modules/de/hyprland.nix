{pkgs, lib, config, ...}: {
  options = {
    de.hyprland.enable = lib.mkEnableOption "Enable hyprland";
    de.hyprland.monitor = lib.mkOption { default = []; };
  };

  config = lib.mkIf config.de.hyprland.enable {
    programs = {
      hyprland.enable = true;
      waybar.enable = true;
    };

    environment.systemPackages = with pkgs; [
      hyprpaper
    ]; 
  };
}
