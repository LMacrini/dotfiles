{ config, lib, powerIcon, ... }: {

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lioma";
  home.homeDirectory = "/home/lioma";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  
  home.file = {
    ".config/starship.toml".source = ../.config/starship.toml;
    ".config/background".source = ../.config/background;
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/lioma/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
  
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = ["scale-monitor-framebuffer"];
      dynamic-workspaces = true;
      workspaces-only-on-primary = true;
    };
    
    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/lioma/.config/background";
      picture-uri-dark = "file:///home/lioma/.config/background";
    };
    
    "org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3-dark";
      color-scheme = "prefer-dark";
      clock-format = "24h";
      accent-color = "blue";
      show-battery-percentage = powerIcon;
    };

    "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
    };

    "org/gnome/shell" = {
      enabled-extensions = ["caffeine@patapon.info" "blur-my-shell@aunetx" "gnome-ui-tune@itstime.tech" "user-theme@gnome-shell-extensions.gcampax.github.com" "just-perfection-desktop@just-perfection" "places-menu@gnome-shell-extensions.gcampax.github.com" "dash-to-dock@micxgx.gmail.com" "appindicatorsupport@rgcjonas.gmail.com"];
      favorite-apps = ["equibop.desktop" "org.gnome.Ptyxis.desktop" "floorp.desktop" "org.gnome.Nautilus.desktop"];
      allow-extensions-installation = true;
    };
    
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Ctrl><Shift><Alt>S" "Print" ];
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
      transparency-mode = "DEFAULT";
    };
    
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      static-blur = false;
    };
    
    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = false;
      events-button = false;
      panel-notification-icon = true;
      power-icon = powerIcon;
      quick-settings = true;
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
    
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-left = [ "<Ctrl><Super>Left" ];
      switch-to-workspace-right = [ "<Ctrl><Super>Right" ];
    };

    "wildmouse/urn" = {
      global-hotkeys = false;
      theme = "live-split";
    };
  };
  
  programs.bash = {
    enable = true;
    initExtra = ''
    [[ $- != *i* ]] && return

    export NO_POINTER_VIEWPORT=1

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    PS1='[\u@\h \W]\$ '

    alias pipinit="source ~/Documents/Python/venv/bin/activate"

    eval "$(zoxide init bash)"

    alias cd="z"
    alias ls="lsd"

    upd-nix-conf() {
      local config=''${1:-default}
      local type=''${2:-switch}
      sudo nixos-rebuild $type --flake "/etc/nixos#$config"
    }
    # eval "$(oh-my-posh init bash --config /home/lioma/.config/oh-my-posh/catppuccin_macchiato.omp.json)"
    eval -- "$(/run/current-system/sw/bin/starship init bash --print-full-init)"
    source "$(blesh-share)/ble.sh"
    '';
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
