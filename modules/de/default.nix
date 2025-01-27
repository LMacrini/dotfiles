{lib, ...}: {
  imports = [
    ./dm.nix
    ./gnome.nix
    ./sway.nix
  ];
  
  de.gnome.enable = lib.mkDefault true;
  de.sway.enable = lib.mkDefault false;
  de.budgie.enable = lib.mkDefault false;
}
