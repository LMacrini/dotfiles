# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  os,
  resources,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./extra-options.nix
    ./libreoffice.nix
    ./shell.nix
  ];

  nix = {
    channel.enable = false;

    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "${config.mainUser}"
        "@wheel"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit os;
      inherit resources;
      cfg = config;
    };
    users = {
      "${config.mainUser}" = import ../../home-manager/lioma;
    };
    useGlobalPkgs = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    fira-code
    nasin-nanpa
  ];

  environment.systemPackages = with pkgs; [
    nh
    nix-output-monitor

    git
    lazygit
    gh
    devenv
    lsd
    skim
    ripgrep
    yazi
    tlrc

    _7zz-rar
    ffmpeg
  ];
}
