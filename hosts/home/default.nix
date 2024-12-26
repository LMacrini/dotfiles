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

  networking.hostName = "DESKTOP-VKFSNVPI";

  configapps.enable = true;
  appimages.enable = true;

  dev.enable = true;
  dev.unity.enable = true;

  games.enable = true;
  obs.enable = true;

  vms.enable = true;

  libreoffice.enable = true;
}
