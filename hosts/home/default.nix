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
  videos.enable = true;

  vms.enable = true;

  libreoffice.enable = true;
}
