# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  ...
} @ params: {
  imports = [
    ./browsers
    ./extra-options.nix
    ./libreoffice.nix
    ./shell.nix
  ];

  nix = {
    channel.enable = false;

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    ];

    registry = {
      config.flake = inputs.self;
      nixpkgs.flake = lib.mkOverride 999 inputs.nixpkgs;
      nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
      zig.flake = inputs.zig;
    };

    settings = {
      experimental-features = "nix-command flakes pipe-operators";
      trusted-users = [
        "root"
        "${config.mainUser}"
        "@wheel"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  home-manager = {
    extraSpecialArgs = {
      inherit (params) inputs os extraHome;
      cfg = config;
    };
    users = {
      "${config.mainUser}" = import ../../home-manager/lioma/from-nixos.nix;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.sessionVariables = {
    DO_NOT_TRACK = 1;
    SKIM_DEFAULT_COMMAND = "${lib.getExe pkgs.fd} --unrestricted --type f";
    SKIM_DEFAULT_OPTIONS = "--layout=reverse --ansi";
    DETSYS_IDS_TELEMETRY = "disabled";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    fira-code
    nasin-nanpa
  ];

  programs.nh = {
    enable = true;
    package = pkgs.unstable.nh; # TODO: use stable in 25.11

    clean = {
      enable = true;
      extraArgs = lib.mkDefault "--keep 3 --keep-since 14d";
      dates = "daily";
    };
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  environment.systemPackages = with pkgs; [
    git
    jujutsu
    skim
    gh
    fd
    ripgrep
    tlrc

    bat
    p7zip-rar
    unzip
    ffmpeg
  ];
}
