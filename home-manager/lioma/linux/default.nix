{
  lib,
  cfg,
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./de
    # ./discord.nix
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  catppuccin = {
    accent = "pink";
    enable = true;

    floorp.profiles = {};
    flavor = "macchiato";
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

  home.packages = with pkgs; [
    catppuccin-cursors.macchiatoDark
    celluloid
    eartag
    eog
    gearlever
    gimp3
    gnome-disk-utility
    peazip
    pkgs.resources # what a genius idea to have a variable named resources
    my.re-lunatic-player
    vlc

    # decide which to use
    # helvum
    qpwgraph
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

  home.shellAliases = {
    chkbd = "sudo --preserve-env=WAYLAND_DISPLAY --preserve-env=XDG_RUNTIME_DIR --preserve-env=XDG_SESSION_TYPE keymapp";
    rmt = "gio trash";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.macchiatoDark;
    name = "catppuccin-macchiato-dark-cursors";
    size = 24;
    hyprcursor = {
      enable = true;
      size = 24;
    };
  };

  xdg = {
    enable = true;

    configFile = {
      "mimeapps.list" = {
        force = true;
      };

      fastfetch = {
        source = ./home/config/fastfetch;
        recursive = true;
      };

      ghostty = {
        source = ./home/config/ghostty;
        recursive = true;
      };

      kanata = {
        source = ./home/config/kanata;
        recursive = true;
      };
    };
    dataFile = {
      "applications/mimeapps.list" = {
        force = true;
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
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = let
        archives = [ "peazip-extract-smart.desktop" ];
        browsers = ["floorp.desktop" "chromium-browser.desktop"];
        images = ["org.gnome.eog.desktop" "gimp.desktop"];
        editors = ["nvim-kitty.desktop" "org.gnome.gedit.desktop"];
      in {
        "application/gzip" = archives;
        "application/x-7z-compressed" = archives;
        "application/x-tar" = archives;
        "application/x-xz" = archives;
        "application/zip" = archives;

        "inode/directory" = ["pcmanfm.desktop" "thunar.desktop" "nautilus.desktop"];
        "x-scheme-handler/https" = browsers;
        "x-scheme-handler/http" = browsers;
        "image/*" = images;
        "image/png" = images;
        "image/jpeg" = images;
        "image/gif" = images;
        "text/*" = editors;
        "text/plain" = editors;
      };
    };

    desktopEntries = {
      nvim = {
        name = "Neovim (hidden)";
        noDisplay = true;
      };
      nvim-kitty = {
        name = "Neovim (kitty)";
        icon = "nvim";
        categories = ["Utility" "TextEditor"];
        genericName = "Text Editor";
        type = "Application";
        startupNotify = false;
        exec = "kitty -- nvim %f";
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;

      extraConfig = {
        XDG_GAMES_DIR = "${config.home.homeDirectory}/Games";
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.rose-pine-icon-theme;
      name = "rose-pine";
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

    ".face" = {
      source = "${pkgs.my.imgs}/share/pfp9696.png";
      executable = false;
      recursive = false;
    };
  };

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = ["scale-monitor-framebuffer"];
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
      cursor-size = 24;
      cursor-theme = "catppuccin-macchiato-dark-cursors";
      document-font-name = "Noto Sans Medium 11";
      font-name = "Noto Sans Medium 11";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "rose-pine";
      monospace-font-name = "FiraCode Nerd Font Mono 10";
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
        "equibop.desktop"
        "com.mitchellh.ghostty.desktop"
        "floorp.desktop"
      ];
      allow-extension-installation = true;
      disable-user-extensions = false;
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [
        "<Shift><Super>S"
        "Print"
      ];
      toggle-application = ["<Alt>space"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screenreader = [];
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
      arcmenu-hotkey = ["<Super>t"];
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
      activate-window-menu = ["<Shift><Control><Alt>1"];
      switch-to-workspace-left = ["<Ctrl><Super>Left"];
      switch-to-workspace-right = ["<Ctrl><Super>Right"];
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = 30;
      recent-files-age = 30;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
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
