{
  pkgs,
  lib,
  config,
  ...
}: {
  options = with lib; {
    de.hyprland = {
      enable = mkEnableOption "hyprland";
      monitor = mkOption {
        default = [];
        type = with types; listOf str;
      };
      hyprlock.enable = mkOption {
        default = true;
        example = false;
        type = types.bool;
      };
    };
  };

  config = lib.mkIf config.de.hyprland.enable {
    programs = {
      hyprland.enable = true;
    };
  };
}
