{...}: {
  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];
  de = {
    hyprland = {
      enable = true;
      monitor = [
        "DP-1,2560x1440@144,0x0,1"
        "HDMI-A-2,1920x1080@144,2560x180,1"
      ];
    };
  };

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
