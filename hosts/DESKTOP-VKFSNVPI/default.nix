{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  shell = "fish";

  dm = "gdm";
  de = {
    hyprland = {
      monitor = [
        "DP-1,2560x1440@144,0x0,1"
        "HDMI-A-2,1920x1080@144,2560x180,1"
      ];
    };
  };

  gpu.amd.enable = true;

  networking.hostName = "DESKTOP-VKFSNVPI";

  games.enable = true;
  games.emulators.enable = true;

  videos.enable = true;

  libreoffice.enable = true;

  stateVersion = "24.11";

  environment.systemPackages = with pkgs; [
    teams-for-linux
  ];

  ssh.enable = true;
}
