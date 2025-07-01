{lib, ...}: {
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
        default = "hyprland";
        type = types.enum [
          "hyprland"
          "gnome"
          "budgie"
          "niri"
        ] |> types.nullOr;
        example = "gnome";
      };
    };
  };
}
