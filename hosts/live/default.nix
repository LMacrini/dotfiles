{
  inputs,
  pkgs,
  modulesPath,
  lib,
  config,
  ...
}: {
  shell = "fish";

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.wireless.enable = false;

  services.displayManager.autoLogin = {
    enable = true;
    user = "lioma";
  };

  de.de = null;
  dm = null;

  users.users = {
    nixos = {
      enable = lib.mkForce false;
    };
  };

  services.getty = {
    autologinUser = lib.mkForce "lioma";
    helpLine = lib.mkForce "";
  };

  bootloader = null;
  kernel = "default";

  liveSystem = true;

  security.sudo.wheelNeedsPassword = false;

  laptop = {
    enable = true;
    tlp.enable = false;
  };

  catppuccin.tty.enable = lib.mkForce true;

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
