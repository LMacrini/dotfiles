{
  inputs,
  pkgs,
  modulesPath,
  lib,
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
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.wireless.enable = false;

  services.displayManager.autoLogin = {
    enable = true;
    user = "lioma";
  };

  laptop = {
    enable = true;
    tlp.enable = false;
  };

  environment.systemPackages = with pkgs; [
    git
    nixinstall
  ];
}
