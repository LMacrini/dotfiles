{
  pkgs,
  cfg,
  lib,
  ...
}:
lib.mkIf cfg.de.hyprland.enable {
  home.packages = with pkgs; [
    blueman
    brightnessctl
    grim
    hypridle
    hyprpaper
    hyprpolkitagent
    kanata
    kitty
    networkmanagerapplet
    pavucontrol
    playerctl
    slurp
    swaynotificationcenter
    xfce.thunar
  ];

  programs = {
    wofi = {
      enable = true;
      settings = {
        allow_images = true;
        gtk_dark = true;
        insensitive = true;
        key_expand = "Shift-Return";
        prompt = ":3";
        show = "drun";
      };
    };

    wlogout = {
      enable = true;
      layout =
        (
          lib.optionals (!cfg.liveSystem) [
            {
              label = "lock";
              action = "hyprlock";
              text = "Lock";
              keybind = "l";
            }
          ]
        )
        ++ [
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

    hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 10;
          hide_cursor = true;
          no_fade_in = false;
        };

        background = [
          {
            path = "~/.config/background.jpg";
            blur_passes = 3;
            blur_size = 8;
          }
        ];
      };
    };

    waybar = import ./waybar;
  };

  services = {
    hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";

        preload = [
          "~/.config/background.jpg"
        ];

        wallpaper = [
          ",~/.config/background.jpg"
        ];
      };
    };
    hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = lib.mkIf (!cfg.liveSystem) "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          # {
          #   timeout = 330;
          #   on-timeout = "hyprctl dispatch dpms off";
          #   on-resume = "hyprctl dispatch dpms on";
          # }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = false;
      variables = ["--all"];
      enableXdgAutostart = true;
    };

    plugins = with pkgs.hyprlandPlugins; [
      hypr-dynamic-cursors
    ];

    settings = {
      "$mod" = "SUPER";

      "plugin:dynamic-cursors" = {
        shake.enabled = false;
      };

      exec-once =
        [
          ''systemd-inhibit --who="Hyprland config" --why="wlogout keybind" --what=handle-power-key --mode=block sleep infinity & echo $! > /tmp/.hyprland-systemd-inhibit''
          "systemctl --user start hyprpolkitagent"
          "hyprpaper"
          "hypridle"
          "waybar"
          "kanata"
          "nm-applet"
          "blueman-applet"
        ]
        ++ (
          lib.optionals cfg.liveSystem
          ["kitty --hold nmtui"]
        );

      exec-shutdown = let
        pkill = n: "pkill ${n} || pkill -9 ${n}";
      in [
        ''kill -9 "$(cat /tmp/.hyprland-systemd-inhibit)"''
        (pkill "kanata")
        (pkill "blueman-applet")
        (pkill "nm-applet")
      ];

      monitor =
        cfg.de.hyprland.monitor
        ++ [
          ", preffered, auto, 1"
        ];

      layerrule = "blur,waybar";

      decoration = {
        rounding = 10;
        # rounding_power = 2.0;
      };

      input = {
        kb_layout = "us,gr";
        kb_variant = "mac,";
        kb_options = "grp:win_space_toggle";

        touchpad = {
          natural_scroll = true;
          scroll_factor = 0.25;
        };
      };

      gestures = {
        workspace_swipe = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
      };

      windowrule = [
        "float, title:Gambling Game"
        "float, title:Bitwarden"
      ];

      env = [
        "NIXOS_OZONE_WL,1"
        # "HYPRCURSOR_THEME,catppuccin-macchiato-dark-cursors"
        # "HYPRCURSOR_SIZE,32"
        # "XCURSOR_THEME,catppuccin-macchiato-dark-cursors"
        # "XCURSOR_SIZE,24"
        # "XDG_CONFIG_HOME,/home/lioma/.config"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindl = [
        ", XF86PowerOff, exec, loginctl lock-session && systemctl suspend"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bind =
        [
          "$mod, T, exec, pkill wofi || wofi"
          "ALT, Space, exec, pkill wofi || wofi"
          "$mod, Q, exec, kitty"
          "$mod, C, killactive"
          "$mod, F, fullscreen"
          "$mod SHIFT, F, togglefloating"
          "$mod ALT, K, exec, pkill kanata && kanata"
          ''SUPER SHIFT, S, exec, pkill slurp || grim -g "$(slurp -dw 0)" - | wl-copy''
          "$mod, right, movefocus, r"
          "$mod, left, movefocus, l"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, down, movewindow, d"
          "$mod SHIFT, up, movewindow, u"
          "SUPER CONTROL, right, workspace, +1"
          "SUPER CONTROL, left, workspace, -1"
          "SUPER SHIFT CONTROL, right, movecurrentworkspacetomonitor, +1"
          "SUPER SHIFT CONTROL, left, movecurrentworkspacetomonitor, -1"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (
              i: let
                ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      animations = {
        enabled = "yes, :3";

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };
    };
  };
}
