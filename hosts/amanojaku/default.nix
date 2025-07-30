{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  gpu.amd.enable = true;

  networking.hostName = "amanojaku";

  games.light.enable = true;

  laptop.enable = true;

  libreoffice.enable = true;

  stateVersion = "25.05";
}
