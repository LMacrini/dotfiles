{config, inputs, pkgs, ...}: {
  imports = [
    ./appimages.nix
    ./bootloader.nix
    ./browsers
    ./config-apps.nix
    ./de
    ./development
    ./extra-options.nix
    ./games
    ./gpu
    ./kernel.nix
    ./keyboards.nix
    ./laptop
    ./videos.nix
    ./vms.nix
    inputs.home-manager.nixosModules.default
  ];

  system = {
    nixos = {
      label = "WamOS-${config.system.nixos.release}";
    };
    stateVersion = config.stateVersion;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    settings.auto-optimise-store = true;
  };

  boot.plymouth = {
    enable = true;
    logo = ./miracle-mallet-icon.png;
    theme = "cross_hud";
    themePackages = with pkgs; [
      adi1090x-plymouth-themes
    ];
  };

  services.gnome.gnome-keyring.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  documentation.nixos.enable = false;

  # Enable CUPS to print documents.
  services = {
    gvfs.enable = true;

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
  };
  boot.kernelModules = ["uinput"];

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
      "video"
    ];
    packages = with pkgs; [
      thunderbird
      unstable.equibop
      bitwarden-desktop
      mediawriter
      teams-for-linux

      fastfetch

      keymapp

      pipes
    ];
  };

  programs.light.enable = true;

  environment.sessionVariables = {
    NH_FLAKE = "/home/${config.mainUser}/dotfiles";
    NH_NOM = 1;
  };

  environment.systemPackages = with pkgs; [
    unstable.peazip
    resources
    unstable.gimp3

    celluloid
    eog
    wl-clipboard

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
}
