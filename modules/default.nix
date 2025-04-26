# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./gpu
    ./development
    ./games
    ./browsers
    ./de
    ./laptop
    ./kernel.nix
    ./bootloader.nix
    ./videos.nix
    ./vms.nix
    ./libreoffice.nix
    ./config-apps.nix
    ./appimages.nix
    ./keyboards.nix
    ./extra-options.nix
    inputs.home-manager.nixosModules.default
  ];

  system.nixos = {
    variantName = "WamOS";
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "lioma"
        "@wheel"
      ];
    };
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  documentation.nixos.enable = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  nixpkgs.config.allowUnfree = true;

  boot.kernelModules = ["uinput"];
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Enable sound with pipewire.
  hardware = {
    pulseaudio.enable = false;
    uinput.enable = true;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  dev.enable = lib.mkDefault false;
  browsers.all.enable = lib.mkDefault false;
  games.enable = lib.mkDefault false;
  videos.enable = lib.mkDefault false;
  vms.enable = lib.mkDefault false;
  libreoffice.enable = lib.mkDefault false;
  configapps.enable = lib.mkDefault false;
  appimages.enable = lib.mkDefault false;

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lioma = {
    hashedPassword = "$6$DuDKsmXNZ0IBeQRk$QDXClqL6ryJ58EsQgfph71HZuNUKRH/BaXksEVkc/lIY2fd.trKorNB72ojne.1akMrcKgvgjqxBiS2fsIXS5/";
    isNormalUser = true;
    description = "Lionel Macrini";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
    ];
    packages = with pkgs; [
      thunderbird
      unstable.equibop
      github-desktop
      bitwarden-desktop
      mediawriter

      fastfetch

      keymapp

      pipes
    ];
  };

  laptop.enable = lib.mkDefault false;

  home-manager = {
    extraSpecialArgs = let
      cfg = config;
    in {
      inherit inputs;
      inherit cfg;
    };
    users = {
      "lioma" = import ../home-manager/lioma;
    };
    useGlobalPkgs = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
    fira-code
    nasin-nanpa
  ];

  environment.sessionVariables = {
    FLAKE = "/home/lioma/dotfiles";
    NH_NOM = 1;
  };

  environment.systemPackages = with pkgs; [
    nh
    nix-output-monitor
    nvd

    git
    gh
    unstable.devenv
    direnv
    alejandra
    zoxide
    lsd
    blesh
    starship
    celluloid
    skim
    wl-clipboard
    yazi

    _7zz-rar
    unstable.peazip

    resources
    gimp

    helvum

    goodvibes
    eartag
  ];

  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "launcher.moe";
        location = "https://gol.launcher.moe/gol.launcher.moe.flatpakrepo";
      }
    ];
    packages = [
      "com.usebottles.bottles"
      # "net.bartkessels.getit"
      # "org.gnome.Showtime"
      # "org.gnome.Decibels"
    ];
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
