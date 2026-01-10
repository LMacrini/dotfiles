{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  programs.nh.clean.extraArgs = "--keep 3 --keep-since 7d";

  gpu.nvidia.enable = true;

  networking.hostName = "lionels-laptop";

  specialisation = {
    hyprland.configuration = {
      system.nixos.tags = [ "hyprland" ];
      de.de = "hyprland";
    };

    gnome.configuration = {
      system.nixos.tags = [ "gnome" ];
      de.de = "gnome";
    };
  };

  games.light.enable = true;
  programs.steam.enable = true;
  games.greentimer.enable = false;

  laptop.enable = true;

  libreoffice.enable = true;

  dm = "tuigreet";
  de = {
    de = lib.mkDefault "niri";
    hyprland = {
      monitor = [
        "eDPI1,1920x1080,0x0,1"
      ];
    };
  };

  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  stateVersion = "24.11";
}
