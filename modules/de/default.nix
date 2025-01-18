{lib, ...}: {
  imports = [
    ./hyprland.nix
  ];
  
  de.hyprland.enable = lib.mkDefault false;
}
