{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

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

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.lioma.extraGroups = ["docker" "libvirtd"];

  networking.hostName = "DESKTOP-VKFSNVPI";

  games.enable = true;
  games.emulators.enable = true;

  videos.enable = true;

  libreoffice.enable = true;

  stateVersion = "24.11";

  ssh.enable = true;

  environment.systemPackages = [
    pkgs.unstable.winboat
    pkgs.freerdp
  ];

  virtualisation.docker.enable = true;
}
