{...}: {
  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];
  de.hyprland.enable = true;

  gpu.amd.enable = true;

  networking.hostName = "DESKTOP-VKFSNVPI";

  kb.cmk-dh.enable = false;

  configapps.enable = true;
  appimages.enable = true;

  dev.enable = true;
  dev.unity.enable = true;

  games.enable = true;
  games.emulators.enable = true;

  videos.enable = true;

  vms.enable = true;

  libreoffice.enable = true;

  ghosttyflake.enable = true;
}
