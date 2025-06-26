# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
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
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  home-manager = {
    extraSpecialArgs = {
      inherit (params) inputs resources os extraHome;
      cfg = config;
    };
    users = {
      "${config.mainUser}" = import ../../home-manager/lioma;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  environment.variables = {
    SKIM_DEFAULT_COMMAND = "fd -ut f";
    SKIM_DEFAULT_OPTIONS = "--layout=reverse --ansi";
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
    skim
    gh
    fd
    unstable.devenv # NOTE: devenv seems to break after a while, can be left on unstable
    ripgrep
    tlrc

    bat

    _7zz-rar
    ffmpeg
  ];
}
