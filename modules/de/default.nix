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
    ./mango.nix
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
            "mango"
          ];
        example = "gnome";
      };

      mango.extraOptions = mkOption {
        default = "";
        type = types.str;
        example = ''
          monitorrule=eDP-1,0.55,1,tile,0,2,0,0,2880,1920,120
        '';
        description = "https://mangowc.vercel.app/docs/configuration/monitors";
      };
    };
  };

  config = {
    guiApps = lib.mkDefault (config.de.de != null);

    niri-flake.cache.enable = config.de.de == "niri";
  };
}
