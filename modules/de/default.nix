{lib, ...}: {
  imports = [
    ./hyprland.nix
  ];
  
  de.hyprland.enable = lib.mkDefault false;
  de.sway.enable = lib.mkDefault false;
}
