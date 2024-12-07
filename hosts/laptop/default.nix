{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ../../modules
  ];

  networking.hostName = "Ordinateur-de-Lionel";

  games.light.enable = true;
  games.greentimer.enable = false;

  tlp.enable = true;

  libreoffice.enable = true;
}
