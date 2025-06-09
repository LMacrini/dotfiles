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
    };
  };

  config = lib.mkIf config.de.hyprland.enable {
    qt.enable = true;

    programs = {
      hyprland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      quickshell
    ];
  };
}
