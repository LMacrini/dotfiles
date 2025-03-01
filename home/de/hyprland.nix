{pkgs, cfg, lib, ...}:
lib.mkIf cfg.de.hyprland.enable {
  home.packages = with pkgs; [
    swaynotificationcenter
    wofi
    hyprpaper
    kanata
  ];

  programs = {
    wlogout = {
      enable = true;
      layout = [
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
          action = "hyprctl exec exit";
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
          action = "systemctl suspend";
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
          # disable_loading_bar = true;
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

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline = 5;
            # placeholder_text = '\'<span foreground="##cad3f5">Password...</span>'\';
            shadow_passes = 2;
          }
        ];
      };
    };

    # hypridle.enable = true;

    waybar = {
      enable = true;
      settings = {
        mainbar = {
          margin-top = 10;
          margin-right = 10;
          margin-left = 10;

          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ 
            "pulseaudio"
            "battery"
            "custom/power"
          ];

          "battery" = {
            format = "{icon} {capacity}%";
            format-charging = "󱐋{icon} {capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };

          "custom/power" = {
            format = "⏻";
            tooltip = false;
            on-click = "wlogout";
          };
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: FiraCode Nerd Font Mono;
        }
        window#waybar {
          /* background: alpha(#1C3981, 0.6); */
          background: rgba(0, 0, 0, 0.5);
          border-radius: 10px;
          border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .module {
          margin-left: 5px;
          margin-right: 5px;
        }
        #custom-power.module {
          margin-right: 10px;
        }
        /* Make the workspace module rounded */
        #workspaces {
          border-radius: 12px;
          padding: 5px 10px;
          transition: background 0.3s ease-in-out;
        }

        #workspaces button {
          border-radius: 8px;
          padding: 0px 10px;
          color: white;
          background: transparent;
          transition: background 0.3s;
        }

        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.7);
        }

        #workspaces button.active {
          background: rgba(255, 255, 255, 0.3);
        }
      '';
    };
  };

  services.hyprpaper = {
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

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = ["--all"];
    settings = {
      "$mod" = "SUPER";

      exec-once = [
        "hyprpaper"
        "waybar"
        "kanata"
      ];

      monitor = cfg.de.hyprland.monitor 
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

      device = [
        {
          name = "zsa-technology-labs-ergodox-ez";
          kb_layout = "us,gr";
          kb_variant = "mac,";
        }
      ];

      gestures = {
        workspace_swipe = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      env = [
        "HYPRCURSOR_THEME,catppuccin-macchiato-dark-cursors"
        "HYPRCURSOR_SIZE,32"
        "XCURSOR_THEME,catppuccin-macchiato-dark-cursors"
        "XCURSOR_THEME,32"
        "XDG_CONFIG_HOME,/home/lioma/.config"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bind = [
        "$mod, T, exec, pkill wofi || wofi --show drun"
        "ALT, Space, exec, pkill wofi || wofi --show drun"
        "$mod, Q, exec, ghostty"
        "$mod, C, killactive"
        "$mod ALT, K, exec, pkill kanata && kanata"
      ] ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
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
    };
  };
}
