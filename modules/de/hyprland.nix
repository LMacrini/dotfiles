{
  lib,
  config,
  ...
}:
{
  options = with lib; {
    de.hyprland = {
      monitor = mkOption {
        default = [ ];
        type = with types; listOf str;
      };
    };
  };

  config = lib.mkIf (config.de.de == "hyprland") {
    qt.enable = true;

    programs = {
      hyprland.enable = true;
    };
  };
}
