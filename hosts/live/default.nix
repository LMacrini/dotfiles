{
  inputs,
  pkgs,
  modulesPath,
  lib,
  config,
  ...
}: {
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.wireless.enable = false;

  services.displayManager.autoLogin = {
    enable = true;
    user = "lioma";
  };

  de.de = null;
  dm = null;

  users = {
    mutableUsers = lib.mkForce true;
    users = {
      nixos = {
        enable = lib.mkForce false;
      };
      lioma = {
        hashedPassword = lib.mkForce null;
      };
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

  environment.systemPackages = with pkgs; [
    acpi
    disko
    git
    my.nixinstall
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  stateVersion = config.system.nixos.release;
}
