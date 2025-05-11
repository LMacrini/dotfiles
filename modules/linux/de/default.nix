{lib, ...}: {
  imports = [
    ./dm.nix
    ./gnome.nix
    ./budgie.nix
    ./hyprland.nix
  ];

  de = {
    hyprland.enable = lib.mkDefault true;
    gnome.enable = lib.mkDefault false;
    budgie.enable = lib.mkDefault false;
  };
}
