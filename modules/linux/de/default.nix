{
  config,
  lib,
  ...
}: {
  imports = [
    ./dm.nix
    ./gnome.nix
    ./sway.nix
    ./budgie.nix
    ./hyprland.nix
  ];

  # disable gnome by default if budgie is enabled since they don't work together
  de = {
    gnome.enable = lib.mkDefault (!config.de.budgie.enable);
    sway.enable = lib.mkDefault false;
    budgie.enable = lib.mkDefault false;
    hyprland.enable = lib.mkDefault false;
  };
}
