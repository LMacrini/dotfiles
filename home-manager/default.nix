{
  lib,
  cfg,
  extraHome,
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./de
    ./emacs
    ./options.nix
    ./packages.nix
    ./trashService.nix
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.wayland-pipewire-idle-inhibit.homeModules.default
    extraHome
  ];

  guiApps = lib.mkDefault cfg.guiApps;

  catppuccin = {
    accent = "pink";
    enable = true;

    cursors = {
      enable = false;
      accent = "dark";
    };

    librewolf.enable = false;
    flavor = "macchiato";
    helix.useItalics = true;
    hyprland.enable = false;
    starship.enable = false;
    waybar.enable = lib.mkDefault false;
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = cfg.mainUser;
  home.homeDirectory = "/home/${cfg.mainUser}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = cfg.stateVersion; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

  home.packages =
    with pkgs;
    [ ]
    ++ lib.optionals config.guiApps [
      cheese
      celluloid
      eartag
      eog
      gearlever
      gimp3
      gnome-disk-utility
      peazip
      resources
      my.re-lunatic-player
      vlc

      # decide which to use
      # helvum
      qpwgraph
    ];

  # NOTE: see xdg.dataFile in this file for toki pona stuff
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-mozc
        fcitx5-gtk
      ];

      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIm = "keyboard-us";
          };

          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "ilo-sitelen";
        };
      };
    };
  };

  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    MOZ_ENABLE_WAYLAND = 1;
  };

  services = {
    flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      packages = lib.optionals config.guiApps [
        "com.usebottles.bottles"
        # "net.bartkessels.getit"
        # "org.gnome.Showtime"
        # "org.gnome.Decibels"
      ];
      update = {
        onActivation = false;
        auto = {
          enable = true;
          onCalendar = "weekly";
        };
      };
    };

    swaync = {
      settings = {
        widgets = [
          "title"
          "dnd"
          "mpris"
          "notifications"
        ];
      };
    };

    wpaperd = {
      settings = {
        any = {
          path = "${pkgs.my.imgs}/share/background.jpg";
        };
      };
    };
  };

  home.shellAliases = {
    chkbd = "sudo --preserve-env=WAYLAND_DISPLAY --preserve-env=XDG_RUNTIME_DIR --preserve-env=XDG_SESSION_TYPE keymapp";
    rmt = "gio trash";
  };

  home.pointerCursor = {
    name = lib.mkDefault "Bibata-Modern-Classic";
    size = lib.mkDefault 24;
    package = lib.mkDefault pkgs.bibata-cursors;

    gtk.enable = true;
    hyprcursor = {
      enable = true;
      size = lib.mkDefault config.home.pointerCursor.size;
    };
    x11.enable = true;
  };

  home.preferXdgDirectories = true;

  xdg = {
    enable = true;

    configFile = {
      "mimeapps.list" = {
        force = true;
      };

      "fourmolu.yaml".source = ./home/config/fourmolu.yaml;

      ghostty = {
        source = ./home/config/ghostty;
        recursive = true;
      };

      kanata = {
        source = ./home/config/kanata;
        recursive = true;
      };
    };
    dataFile =
      let
        ilo-sitelen = pkgs.stdenvNoCC.mkDerivation {
          name = "ilo-sitelen";
          version = "1.0";

          src = pkgs.fetchFromGitHub {
            owner = "balt-dev";
            repo = "ilo-sitelen";
            rev = "3c6e0010ef51f740737f8ae1ee43402e9de5cd51";
            hash = "sha256-Mx/u63ZE8uMrdAG/4MsOtQr0Mm5V3Yp9AH0n6y1jBew=";
          };

          installPhase = ''
            mkdir -p $out/share
            cp -r $src/table $out/share
            cp -r $src/inputmethod $out/share
          '';
        };
      in
      {
        "applications/mimeapps.list" = {
          force = true;
        };

        "fcitx5/table" = {
          source = ilo-sitelen + "/share/table";
          recursive = true;
        };

        "fcitx5/inputmethod" = {
          source = ilo-sitelen + "/share/inputmethod";
          recursive = true;
        };
      };

    portal = {
      enable = true;
      config = {
        common = {
          default = [
            "gtk"
          ];
        };

        gnome = {
          default = [
            "gnome"
            "gtk"
          ];
        };

        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
        };

        niri = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };
      extraPortals =
        with pkgs;
        [
          xdg-desktop-portal-gtk
        ]
        ++ lib.optional (cfg.de.de == "gnome") xdg-desktop-portal-gnome
        ++ lib.optional (cfg.de.de == "hyprland") xdg-desktop-portal-hyprland
        ++ lib.optional (cfg.de.de == "niri") xdg-desktop-portal-gnome;
    };

    mimeApps = {
      enable = true;
      defaultApplications =
        let
          archives = [ "peazip-extract-smart.desktop" ];
          audio = videos ++ [ "app.drey.EarTag.desktop" ];
          browsers = [
            "librewolf.desktop"
            "chromium-browser.desktop"
          ];
          images = [
            "org.gnome.eog.desktop"
            "gimp.desktop"
          ];
          videos = [
            "io.github.celluloid_player.Celluloid.desktop"
            "vlc.desktop"
          ];
          editors = [
            "helix-kitty.desktop"
            "nvim-kitty.desktop"
            "org.gnome.gedit.desktop"
          ];
        in
        {
          "application/pdf" = [ "sioyek.desktop" ] ++ browsers;
          "application/gzip" = archives;
          "application/x-7z-compressed" = archives;
          "application/x-bzip2" = archives;
          "application/x-tar" = archives;
          "application/x-xz" = archives;
          "application/zip" = archives;

          "audio/*" = audio;
          "audio/mpeg" = audio;
          "audio/x-opus+ogg" = audio;

          "inode/directory" = [
            "thunar.desktop"
            "org.gnome.Nautilus.desktop"
            "pcmanfm.desktop"
          ];
          "x-scheme-handler/https" = browsers;
          "x-scheme-handler/http" = browsers;
          "text/html" = browsers;

          "x-scheme-handler/terminal" = [
            "kitty.desktop"
            "com.mitchellh.ghostty.desktop"
          ];
          "image/*" = images;
          "image/gif" = images;
          "image/jpeg" = images;
          "image/png" = images;
          "image/svg+xml" = images;
          "image/webp" = images;
          "video/*" = videos;
          "video/mp4" = videos;
          "video/x-matroska" = videos;
          "text/*" = editors;
          "text/plain" = editors;
        };
    };

    desktopEntries = {
      Helix = {
        name = "Helix (hidden)";
        noDisplay = true;
      };
      helix-kitty = {
        name = "Helix (kitty)";
        icon = "helix";
        categories = [
          "Utility"
          "TextEditor"
        ];
        genericName = "Text Editor";
        type = "Application";
        startupNotify = false;
        exec = "kitty -- hx %f";
      };

      kitty-no-tmux = lib.mkIf (config.programs.kitty.enable || config.programs.tmux.enable) {
        name = "kitty (no tmux)";
        icon = "kitty";
        categories = [
          "System"
          "TerminalEmulator"
        ];
        comment = "Fast, feature-rich, GPU based terminal";
        genericName = "Terminal Emulator";
        type = "Application";
        startupNotify = true;
        exec = "env DISABLE_TMUX=1 kitty";
      };

      weechat = {
        name = "WeeChat (hidden)";
        noDisplay = true;
      };

      weechat-kitty = {
        name = "WeeChat (kitty)";
        icon = "weechat";
        categories = [
          "Network"
          "Chat"
          "IRCClient"
          "ConsoleOnly"
        ];
        comment = "Extensible chat client";
        genericName = "Chat client";
        type = "Application";
        mimeType = [
          "x-scheme-handler/irc"
          "x-scheme-handler/ircs"
        ];
        exec = "kitty -T WeeChat -- weechat %u";
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;

      extraConfig = {
        XDG_GAMES_DIR = "${config.home.homeDirectory}/Games";
        XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme = 1
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  home.file = {
    "Templates" = {
      source = ./home/Templates;
      recursive = true;
    };
  };

  programs = {
    sioyek.enable = config.guiApps;
  };

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
      dynamic-workspaces = true;
      workspaces-only-on-primary = true;
    };

    "org/gnome/applications/terminal" = {
      exec = "ghostty";
    };

    "org/gnome/desktop/background" = {
      picture-uri = "${pkgs.my.imgs}/share/background.jpg";
      picture-uri-dark = "${pkgs.my.imgs}/share/background.jpg";
    };

    "org/gnome/desktop/interface" = {
      accent-color = "blue";
      clock-format = "24h";
      color-scheme = "prefer-dark";
      cursor-theme = config.gtk.cursorTheme.name;
      cursor-size = config.gtk.cursorTheme.size;
      document-font-name = "Noto Sans Medium 11";
      font-name = "Noto Sans Medium 11";
      gtk-theme = "adw-gtk3-dark";
      monospace-font-name = "${cfg.fonts.nerdfont.nlName} 10";
      show-battery-percentage = cfg.laptop.enable;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.gvariant.mkTuple [
          "xkb"
          "us+mac"
        ])
        (lib.gvariant.mkTuple [
          "xkb"
          "gr"
        ])
      ];
      show-all-sources = true;
      xkb-options = [
        "terminate:ctrl_alt_bksp"
        "nbsp:zwnj2nb3zwj4"
      ];
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "arcmenu@arcmenu.com"
        "caffeine@patapon.info"
        "blur-my-shell@aunetx"
        "gnome-ui-tune@itstime.tech"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "just-perfection-desktop@just-perfection"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "quick-settings-audio-panel@rayzeq.github.io"
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "discord.desktop"
        "kitty.desktop"
        "librewolf.desktop"
      ];
      allow-extension-installation = true;
      disable-user-extensions = false;
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [
        "<Shift><Super>S"
        "Print"
      ];
      toggle-application = [ "<Alt>space" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screenreader = [ ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = false;
      background-opacity = 0.8;
      custom-background-color = false;
      dash-max-icon-size = 48;
      dock-fixed = false;
      dock-position = "BOTTOM";
      height-fraction = 0.9;
      intellihide = false;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
      running-indicator-style = "BINARY";
      show-mounts = false;
      show-trash = false;
      transparency-mode = "DEFAULT";
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      static-blur = false;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = false;
      events-button = false;
      panel-notification-icon = true;
      power-icon = cfg.laptop.enable;
      quick-settings = true;
      support-notifier-type = 0;
      window-demands-attention-focus = true;
      window-menu-take-screenshot-button = true;
      window-picker-icon = true;
      workspace-switcher-should-show = true;
      world-clock = false;
    };

    "org/gnome/shell/extensions/appindicator" = {
      icon-size = 20;
      legacy-tray-enabled = false;
    };

    "org/gnome/shell/extensions/arcmenu" = {
      arcmenu-hotkey = [ "<Super>t" ];
      menu-button-appearance = "None";
      menu-layout = "Runner";
      position-in-panel = "Center";
      runner-position = "Centered";
      runner-search-display-style = "Grid";
      search-provider-recent-files = true;
      show-activities-button = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":close";
      focus-mode = "sloppy";
      resize-with-right-button = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = [ "<Shift><Control><Alt>1" ];
      switch-to-workspace-left = [ "<Ctrl><Super>Left" ];
      switch-to-workspace-right = [ "<Ctrl><Super>Right" ];
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = 30;
      recent-files-age = 30;
      remove-old-temp-files = true;
      remove-old-trash-files = cfg.de.de == "gnome";
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };

    "wildmouse/urn" = {
      global-hotkeys = false;
      theme = "live-split";
    };
  };
}
