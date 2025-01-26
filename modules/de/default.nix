{lib, ...}: {
  imports = [
    ./dm.nix
    ./gnome.nix
    ./hyprland.nix
    ./sway.nix
  ];
  
  de.gnome.enable = lib.mkDefault true;
  de.hyprland.enable = lib.mkDefault false;
  de.sway.enable = lib.mkDefault false;
}
