{
  pkgs,
  cfg,
  config,
  lib,
  resources,
  ...
}:
lib.mkIf (cfg.de.de == "niri") {
  programs.niri.settings = let
    fuzzel = {
      hotkey-overlay.title = "Run an Application: fuzzel";
      action.spawn = "fuzzel";
    };
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

        "Mod+Ctrl+Left".action = move-column-left;
        "Mod+Ctrl+Down".action = move-column-to-workspace-down;
        "Mod+Ctrl+Up".action = move-column-to-workspace-up;
        "Mod+Ctrl+Right".action = move-column-right;

        "Mod+Shift+Left".action = focus-monitor-left;
        "Mod+Shift+Down".action = focus-monitor-down;
        "Mod+Shift+Up".action = focus-monitor-up;
        "Mod+Shift+Right".action = focus-monitor-right;

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
        "Mod+Ctrl+F".action = toggle-windowed-fullscreen;
        "Mod+L" = {
          repeat = false;
          action = spawn "wlogout";
        };

        # TODO: figure out how this should work on the ergodox
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        "Super+Shift+S".action = screenshot;

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
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
      touchpad = {
        dwt = true;
      };
    };

    screenshot-path = "~/Pictures/Screenshots/screenshot-%Y-%m-%d %H-%M-%S.png";

    spawn-at-startup = [
      {command = ["kanata"];}
      {command = ["waybar"];}
      {command = ["swww" "img" "${resources}/background.jpg"];}
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
    fuzzel.enable = true;
    kitty.enable = true;
    swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        clock = true;
        daemonize = true;
        effect-blur = "7x5";
        fade-in = 1;
        image = "${resources}/background.jpg";
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
          command = "${swaylock}/bin/swaylock";
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
    pavucontrol
    pcmanfm
    sway-audio-idle-inhibit
  ];

  catppuccin.waybar.enable = true;
}
