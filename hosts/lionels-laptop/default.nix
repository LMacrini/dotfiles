{...}: {
  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];
  gpu.nvidia.enable = true;

  networking.hostName = "lionels-laptop";

  games.light.enable = true;
  games.greentimer.enable = false;

  laptop.enable = true;

  libreoffice.enable = true;

  dev.editors.enable = true;

  de.hyprland = {
    enable = true;
    monitor = [
      "eDPI1,1920x1080,0x0,1"
    ];
  };

  de.gnome.enable = false;
  dm = "ly";

  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
}
