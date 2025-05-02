{
  inputs,
  pkgs,
  modulesPath,
  lib,
  config,
  ...
}: let
  nixinstall = pkgs.writeTextFile {
    name = "nixinstall";
    executable = true;
    destination = "/bin/nixinstall";
    text = builtins.readFile ./script.sh;
  };
in {
  imports = [
    # "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.wireless.enable = false;

  services.displayManager.autoLogin = {
    enable = true;
    user = "lioma";
  };

  de = {
    gnome.enable = false;
    hyprland.enable = true;
  };
  dm = "gdm";

  liveSystem = true;

  laptop = {
    enable = true;
    tlp.enable = false;
  };

  environment.systemPackages = with pkgs; [
    git
    nixinstall
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  stateVersion = config.system.nixos.release;
}
