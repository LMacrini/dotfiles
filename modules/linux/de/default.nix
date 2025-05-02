{
  config,
  lib,
  ...
}: {
  imports = [
    ./dm.nix
    ./gnome.nix
    ./budgie.nix
    ./hyprland.nix
  ];

  # disable gnome by default if budgie is enabled since they don't work together
  de = {
    gnome.enable = lib.mkDefault (!config.de.budgie.enable);
    budgie.enable = lib.mkDefault false;
    hyprland.enable = lib.mkDefault false;
  };
}
