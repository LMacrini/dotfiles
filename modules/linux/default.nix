{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./bootloader.nix
    ./de
    ./extra-options.nix
    ./games
    ./gpu
    ./kernel.nix
    ./laptop
    ./plymouth
    ./ssh.nix
    ./videos.nix
    inputs.home-manager.nixosModules.default
  ];

  system = {
    nixos = {
      label = "WamOS-${config.system.nixos.release}";
    };
    inherit (config) stateVersion;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = lib.mkDefault "--delete-older-than 14d";
    };

    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://catppuccin.cachix.org"
        "https://unmojang.cachix.org"
      ];
      trusted-public-keys = [
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
        "unmojang.cachix.org-1:OfHnbBNduZ6Smx9oNbLFbYyvOWSoxb2uPcnXPj4EDQY="
      ];
    };
  };

  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "pink";
    limine.enable = false;
    plymouth.enable = false;
    tty.enable = false;
  };

  services.gnome.gnome-keyring.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = lib.mkDefault "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  documentation.nixos.enable = false;

  # Enable CUPS to print documents.
  services = {
    accounts-daemon.enable = true;
    blueman.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;

    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';
    pulseaudio.enable = false;
  };
  boot = {
    tmp = {
      cleanOnBoot = true;
    };

    kernelModules = [
      "uinput"
      "i2c-dev"
    ];
  };

  # Enable sound with pipewire.
  hardware = {
    bluetooth.enable = true;
    uinput.enable = true;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  users = {
    mutableUsers = false;
    users.lioma = {
      isNormalUser = true;
      description = "Lionel Macrini";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "uinput"
        "video"
      ];
      hashedPassword = lib.mkDefault "$y$j9T$MVARZZBLm43XHuw9mceTd1$Ij0wQ0GJ5YwJinZlm0e4IWK2Bq8VHN/Kbe3xvQ58B22";
      packages = with pkgs; [
        thunderbird
        (unstable.equibop.override {electron = electron_36;})
        bitwarden-desktop
        mediawriter

        fastfetch

        keymapp

        pipes
      ];
    };
  };

  programs = {
    appimage = {
      enable = true;
      binfmt = true;
    };
    light.enable = true;
    nano.enable = false;
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };

  environment.etc."programs.sqlite".source = inputs.programsdb.packages.${pkgs.system}.programs-sqlite;
  programs.command-not-found.dbPath = "/etc/programs.sqlite";

  environment.sessionVariables = {
    NH_FLAKE = "/home/${config.mainUser}/dotfiles";
    NH_NOM = 1;
  };

  environment.systemPackages = with pkgs; [
    glib
    wl-clipboard
    inputs.home-manager.packages.${stdenv.system}.default
  ];

  environment.pathsToLink = ["/share/xdg-desktop-portal" "/share/applications"]; # see https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable

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
    ];
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
