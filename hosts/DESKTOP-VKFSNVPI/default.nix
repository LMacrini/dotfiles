{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  dm = "gdm";
  de = {
    de = "mango";
    hyprland = {
      monitor = [
        "DP-1,2560x1440@144,0x0,1"
        "HDMI-A-2,1920x1080@144,2560x180,1"
      ];
    };

    mango.extraOptions = ''
      # monitorrule = DP-1,0.55,1,tile,1,0,0,2560,1440,144
      # exec-once = ${lib.getExe pkgs.wlr-randr} --output HDMI-A-2 --pos 2560,180 --mode 1920x1080@144.001Hz
      monitorrule = name:DP-1,width:2560,height:1440,refresh:144
      monitorrule = name:HDMI-A-2,width:1920,height:1080,refresh:144.001,x:2560,y:180
    '';
  };

  specialisation = {
    LTS.configuration = {
      environment.etc.specialisation.text = "LTS";
      system.nixos.tags = [ "LTS" ];

      kernel = "lts";
    };
  };

  gpu.amd.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.lioma.extraGroups = [
    "docker"
    "libvirtd"
  ];

  networking.hostName = "DESKTOP-VKFSNVPI";

  games.enable = true;
  games.emulators.enable = true;

  videos.enable = true;

  libreoffice.enable = true;

  stateVersion = "24.11";

  ssh.enable = true;

  environment.systemPackages = [
    # pkgs.winboat
    pkgs.freerdp
  ];

  virtualisation.docker.enable = true;
}
