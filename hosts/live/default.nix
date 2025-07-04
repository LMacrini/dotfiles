{
  inputs,
  pkgs,
  modulesPath,
  lib,
  config,
  ...
}: {
  shell = "nu";

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.wireless.enable = false;

  services.displayManager.autoLogin = {
    enable = true;
    user = "lioma";
  };

  dm = "gdm";

  bootloader = null;
  kernel = "default";

  liveSystem = true;

  security.sudo.wheelNeedsPassword = false;

  laptop = {
    enable = true;
    tlp.enable = false;
  };

  environment.systemPackages = with pkgs; [
    git
    disko
    my.nixinstall
    my.nixinstall-zig
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  stateVersion = config.system.nixos.release;
}
