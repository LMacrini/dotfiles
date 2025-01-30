{...}: {

  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];
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

  users.users.lioma = {
    extraGroups = [
      "podman"
    ];
  };

  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

}
