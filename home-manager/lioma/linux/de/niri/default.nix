{
  pkgs,
  cfg,
  config,
  lib,
  ...
}:
lib.mkIf (cfg.de.de == "niri") {
  programs.niri.settings = let
    fuzzel = {
      hotkey-overlay.title = "Run an Application: fuzzel";
      action.spawn = lib.getExe pkgs.fuzzel;
    };

    brightnessctl = lib.getExe pkgs.brightnessctl;
    wpctl = "${pkgs.wireplumber}/bin/wpctl";
  in {
    binds = with config.lib.niri.actions;
      {
        "Mod+Shift+Slash".action = show-hotkey-overlay;
        "Mod+Q" = {
          hotkey-overlay.title = "Open a Terminal: kitty";
          action.spawn = ["env" "-u" "SHLVL" "kitty"];
        };
        "Mod+Shift+E".action = quit;
        "Ctrl+Alt+Delete".action = quit;

        "Mod+C".action = close-window;

        "Alt+Space" = fuzzel;
        "Mod+T" = fuzzel;

        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-workspace-down;
        "Mod+Up".action = focus-workspace-up;
        "Mod+Right".action = focus-column-right;

        "Mod+Ctrl+Left".action = focus-monitor-left;
        "Mod+Ctrl+Down".action = focus-monitor-down;
        "Mod+Ctrl+Up".action = focus-monitor-up;
        "Mod+Ctrl+Right".action = focus-monitor-right;

        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Down".action = move-column-to-workspace-down;
        "Mod+Shift+Up".action = move-column-to-workspace-up;
        "Mod+Shift+Right".action = move-column-right;

        "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;

        "Mod+M".action = maximize-column;
        "Mod+Y" = {
          repeat = false;
          action = toggle-overview;
        };
        "Mod+F".action = fullscreen-window;
        "Mod+Shift+F".action = toggle-window-floating;
        "Mod+Ctrl+F".action = switch-focus-between-floating-and-tiling;
        "Mod+Shift+Ctrl+F".action = toggle-windowed-fullscreen;
        "Mod+L" = {
          repeat = false;
          hotkey-overlay.title = "Open Logout Menu: wlogout";
          action = spawn "sh" "-c" "pkill wlogout || wlogout";
        };
        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;

        # TODO: figure out how this should work on the ergodox
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        "Super+Shift+S".action = screenshot {
          show-pointer = false;
        };

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn wpctl "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = spawn wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = spawn wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action = spawn brightnessctl "s" "10%+";
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action = spawn brightnessctl "s" "10%-";
        };
      }
      // (
        builtins.listToAttrs (
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                {
                  name = "Mod+${toString ws}";
                  value.action.focus-workspace = ws;
                }
                {
                  name = "Mod+Shift+${toString ws}";
                  value.action.move-window-to-workspace = ws;
                }
              ]
            )
            9)
        )
      );

    clipboard.disable-primary = true;

    gestures = {
      hot-corners.enable = false;
    };

    hotkey-overlay.skip-at-startup = lib.mkDefault true;

    input = {
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "95%";
      };

      touchpad = {
        dwt = true;
      };
    };
    
    layout = {
      always-center-single-column = true;

      preset-column-widths = [
        { proportion = 1.0 / 3.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 2.0 / 3.0; }
      ];

      preset-window-heights = [
        { proportion = 1.0; }
        { proportion = 1.0 / 3.0; }
        { proportion = 1.0 / 2.0; }
        { proportion = 2.0 / 3.0; }
      ];
    };

    screenshot-path = "~/Pictures/Screenshots/screenshot-%Y-%m-%d %H-%M-%S.png";

    spawn-at-startup = [
      {command = ["kanata"];}
      {command = ["waybar"];}
      {command = ["swww" "img" "${pkgs.my.imgs}/share/background.jpg"];}
      {command = ["sway-audio-idle-inhibit"];}
    ];

    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    xwayland-satellite = {
      enable = true;
      path = lib.getExe pkgs.xwayland-satellite-unstable;
    };
  };

  programs = {
    fuzzel.enable = true; # this is for catppuccin nix to affect fuzzel, if i didn't want to configure it at all i could not enable it
    kitty = {
      enable = true;
      settings = {
        hide_window_decorations = "yes";
      };
    };
    swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        clock = true;
        daemonize = true;
        effect-blur = "7x5";
        fade-in = 1;
        image = "${pkgs.my.imgs}/share/background.jpg";
        indicator = true;
        ring-color = lib.mkForce "717df1";
      };
    };
    waybar = import ./waybar;

    wlogout = {
      enable = true;
      layout = lib.mkDefault [
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "logout";
          action = "hyprctl dispatch exit";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "loginctl lock-session && systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
    };
  };

  services = {
    blueman-applet.enable = true;
    network-manager-applet.enable = true;

    swayidle = let
      swaylock = config.programs.swaylock.package;
    in {
      enable = true;
      events = [
        {
          event = "before-sleep";
          command = "${swaylock}/bin/swaylock --fade-in 0";
        }
        {
          event = "lock";
          command = "${swaylock}/bin/swaylock --grace 10";
        }
      ];
      timeouts = [
        {
          timeout = 150;
          command = "brightnessctl -s set 10";
          resumeCommand = "brightnessctl -r";
        }
        {
          timeout = 300;
          command = "loginctl lock-session";
        }
        {
          timeout = 900;
          command = "systemctl suspend";
        }
      ];
    };
    swaync.enable = true;
    swww.enable = true;
  };

  systemd.user.services = {
    blueman-applet = {
      Unit.After = ["network-manager-applet.service"];
    };
  };

  home.packages = with pkgs; [
    kanata
    nautilus
    pavucontrol
    sway-audio-idle-inhibit
  ];

  catppuccin.waybar.enable = true;
}
