{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  shell = "nu";

  gpu.nvidia.enable = true;

  networking.hostName = "lionels-laptop";

  games.light.enable = true;
  games.greentimer.enable = false;

  laptop.enable = true;

  libreoffice.enable = true;

  de = {
    de = "niri";
    hyprland = {
      monitor = [
        "eDPI1,1920x1080,0x0,1"
      ];
    };
  };

  time.timeZone = "Europe/Zurich";

  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  stateVersion = "24.11";
}
