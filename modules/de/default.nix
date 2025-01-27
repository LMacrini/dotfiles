{config, lib, ...}: {
  imports = [
    ./dm.nix
    ./gnome.nix
    ./sway.nix
    ./budgie.nix
  ];
  
  # disable gnome by default if budgie is enabled since they don't work together
  de.gnome.enable = lib.mkDefault (!config.de.budgie.enable);
  de.sway.enable = lib.mkDefault false;
  de.budgie.enable = lib.mkDefault false;
}
