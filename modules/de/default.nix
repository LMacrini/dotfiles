{
  lib,
  config,
  ...
}:
{
  imports = [
    ./dm.nix
    ./gnome.nix
    ./budgie.nix
    ./hyprland.nix
    ./niri.nix
  ];

  options = with lib; {
    de = {
      de = mkOption {
        default = "niri";
        type =
          types.nullOr
          <| types.enum [
            "hyprland"
            "gnome"
            "budgie"
            "niri"
          ];
        example = "gnome";
      };
    };
  };

  config = lib.mkIf (config.de.de == null) {
    guiApps = lib.mkDefault false;
  };
}
