# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  hmPath,
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
      cfg = config;
    };
    users = {
      "${config.mainUser}" = import "${hmPath}/lioma";
    };
    useGlobalPkgs = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
    fira-code
    nasin-nanpa
  ];

  environment.systemPackages = with pkgs; [
    unstable.nh
    nix-output-monitor

    git
    lazygit
    gh
    devenv
    direnv
    alejandra
    zoxide
    lsd
    skim
    yazi
    tlrc

    _7zz-rar
  ];
}
