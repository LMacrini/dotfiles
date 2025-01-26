{lib, ...}: {
  imports = [
    ./hyprland.nix
    ./sway.nix
  ];
  
  de.hyprland.enable = lib.mkDefault false;
  de.sway.enable = lib.mkDefault false;
}
