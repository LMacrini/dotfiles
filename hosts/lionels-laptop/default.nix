{ ... }: {

  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];
  gpu.nvidia.enable = true;

  networking.hostName = "lionels-laptop";

  games.light.enable = true;
  games.greentimer.enable = false;

  laptop.tlp.enable = true;

  libreoffice.enable = true;
  
  dev.editors.enable = true;
}
