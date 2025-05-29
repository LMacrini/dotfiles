# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  os,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./extra-options.nix
    ./libreoffice.nix
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

  programs = {
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nushell

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
