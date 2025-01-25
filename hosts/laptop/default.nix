{ ... }: {

  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];

  networking.hostName = "lionels-laptop";

  games.light.enable = true;
  games.greentimer.enable = false;

  tlp.enable = true;

  libreoffice.enable = true;
}
