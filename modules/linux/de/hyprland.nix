{
  pkgs,
  lib,
  config,
  ...
}: {
  options = with lib; {
    de.hyprland = {
      monitor = mkOption {
        default = [];
        type = with types; listOf str;
      };
      quickshell = mkEnableOption "quickshell";
    };
  };

  config = lib.mkIf (config.de.de == "hyprland") {
    qt.enable = true;

    programs = {
      hyprland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      (lib.mkIf config.de.hyprland.quickshell quickshell)
    ] |> builtins.filter (x: x != null);
  };
}
