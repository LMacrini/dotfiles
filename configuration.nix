# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "DESKTOP-VKFSNVPI"; # Define your hostname.
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

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    excludePackages = [ pkgs.xterm ];

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "symbolic";
    };
  };
  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  nixpkgs.config.allowUnfree = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
    totem
    geary
    epiphany
    yelp
    gnome-system-monitor
  ]);
  
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lioma = {
    isNormalUser = true;
    description = "Lionel Macrini";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [
    #  thunderbird
      equibop
      github-desktop
      unstable.vscode
      obs-studio
      peazip
      bitwarden-desktop
      mediawriter
      
      fastfetch

      urn-timer
      keymapp
    ];
  };
  
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "lioma" = import ./home.nix;
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    fira-code
    nasin-nanpa
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    zig
    git
    ptyxis
    neovim
    zoxide
    lsd
    blesh
    starship
    floorp
    celluloid
    
    mission-center

    adw-gtk3
    gnome-tweaks
    gnomeExtensions.blur-my-shell
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.user-themes
    gnomeExtensions.caffeine
    gnomeExtensions.gnome-40-ui-improvements
    gnomeExtensions.just-perfection
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    
    dconf-editor
    dconf2nix

    helvum
  ];
  
  services.flatpak = {
    enable = true;
    remotes = [
      { name = "flathub"; location = "https://dl.flathub.org/repo/flathub.flatpakrepo"; }
      { name = "launcher.moe"; location = "https://gol.launcher.moe/gol.launcher.moe.flatpakrepo"; }
    ];
    packages = [
      { flatpakref = "https://sober.vinegarhq.org/sober.flatpakref"; sha256="1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l"; }
      { appId = "moe.launcher.an-anime-game-launcher"; origin = "launcher.moe"; }
      # { appId = "moe.launcher.the-honkers-railway-launcher"; origin = "launcher.moe"; }
      # { appId = "moe.launcher.honkers-launcher"; origin = "launcher.moe"; }
      # { appId = "moe.launcher.sleepy-launcher"; origin = "launcher.moe"; }
      "com.usebottles.bottles"
      # "net.bartkessels.getit"
      "it.mijorus.gearlever"
      # "org.gnome.Showtime"
      # "org.gnome.Decibels"
    ];
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
