{
  pkgs,
  lib,
  config,
  ...
}: {
  options = with lib; {
    de.hyprland.enable = mkEnableOption "Enable hyprland";
    de.hyprland.monitor = mkOption {
      default = [];
      type = with types; listOf str;
    };
  };

  config = lib.mkIf config.de.hyprland.enable {
    programs = {
      hyprland.enable = true;
    };
  };
}
