{
  pkgs,
  config,
  lib,
  ...
}:
let
  brightnessctl = lib.getExe pkgs.brightnessctl;
  loginctl = lib.getExe' pkgs.systemd "loginctl";
  rofi = lib.getExe config.programs.rofi.finalPackage;
  swaylock = lib.getExe config.programs.swaylock.package;
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  wpctl = lib.getExe' pkgs.wireplumber "wpctl";
  anyrun = lib.getExe config.programs.anyrun.package;
  wlogout = lib.getExe config.programs.wlogout.package;
in
{
  imports = [
    ./waybar
  ];

  programs.niri.settings =
    let
      spawn-rofi = {
        hotkey-overlay.title = "Run an Application: rofi";
        action.spawn = [
          rofi
          "-show"
          "drun"
        ];
      };
      spawn-anyrun = {
        hotkey-overlay.title = "Run an Application: anyrun";
        action.spawn-sh = "pkill anyrun || ${anyrun}";
      };
    in
    {
      binds =
        with config.lib.niri.actions;
        {
          "Mod+Shift+Slash".action = show-hotkey-overlay;
          "Mod+Q" = {
            hotkey-overlay.title = "Open a Terminal: kitty";
            action = spawn "kitty";
          };
          "Mod+Shift+E".action = quit;
          "Ctrl+Alt+Delete".action = quit;

          "Mod+C".action = close-window;

          "Alt+Space" = spawn-anyrun;
          "Mod+T" = spawn-anyrun;

          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-down;
          "Mod+Up".action = focus-window-up;
          "Mod+Right".action = focus-column-right;

          "Mod+Ctrl+Left".action = focus-monitor-left;
          "Mod+Ctrl+Down".action = focus-monitor-down;
          "Mod+Ctrl+Up".action = focus-monitor-up;
          "Mod+Ctrl+Right".action = focus-monitor-right;

          "Mod+Shift+Left".action = move-column-left;
          "Mod+Shift+Down".action = move-window-down;
          "Mod+Shift+Up".action = move-window-up;
          "Mod+Shift+Right".action = move-column-right;

          "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;

          "Mod+S".action = move-workspace-to-monitor-next;

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
            action = spawn-sh "pkill wlogout || ${wlogout}";
          };
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;

          "Mod+Comma".action = consume-or-expel-window-left;
          "Mod+Period".action = consume-or-expel-window-right;

          "Super+Shift+S" = {
            repeat = false;
            action.screenshot.show-pointer = false;
          };

          "Mod+W".action = set-dynamic-cast-window;
          "Mod+Shift+W".action = set-dynamic-cast-monitor;
          "Mod+Ctrl+W".action = clear-dynamic-cast-target;

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
        // (builtins.listToAttrs (
          builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                {
                  name = "Mod+${toString ws}";
                  value.action.focus-workspace = ws;
                }
                {
                  name = "Mod+Shift+${toString ws}";
                  value.action.move-window-to-workspace = ws;
                }
                {
                  name = "Mod+Ctrl+${toString ws}";
                  value.action.move-workspace-to-index = ws;
                }
              ]
            ) 9
          )
        ));

      clipboard.disable-primary = true;

      cursor = {
        hide-when-typing = true;
        size = config.home.sessionVariables.XCURSOR_SIZE;
        theme = config.home.sessionVariables.XCURSOR_THEME;
      };

      gestures = {
        hot-corners.enable = false;
      };

      hotkey-overlay = {
        hide-not-bound = true;
        skip-at-startup = lib.mkDefault true;
      };

      input = {
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "10%";
        };

        keyboard = {
          xkb = {
            layout = "us,gr";
            options = "grp:win_space_toggle";
            variant = "mac,";
          };
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

      prefer-no-csd = true;

      screenshot-path = "~/Pictures/Screenshots/screenshot-%Y-%m-%d %H-%M-%S.png";

      spawn-at-startup = [
        { command = [ "kanata" ]; }
        { command = [ "waybar" ]; }
        { command = [ "kitty" ]; }
      ];

      switch-events = {
        lid-close.action.spawn = [
          systemctl
          "suspend"
        ];
      };

      window-rules = [
        {
          matches = [
            {
              app-id = "steam";
              title = "^notificationtoasts_\\d+_desktop$";
            }
          ];
          default-floating-position = {
            x = 10;
            y = 10;
            relative-to = "bottom-right";
          };
          open-focused = false;
        }
        {
          matches = [
            {
              app-id = "Bitwarden";
            }
          ];

          block-out-from = "screen-capture";
        }
        {
          matches = [
            {
              title = "Python Turtle Graphics";
            }
            {
              title = "Vulkan";
            }
          ];
          open-floating = true;
        }
      ];

      xwayland-satellite = {
        enable = true;
        path = lib.getExe pkgs.xwayland-satellite;
      };
    };

  programs = {

    anyrun = {
      enable = true;
      config = {
        x = {
          fraction = 0.5;
        };
        y = {
          fraction = 0.3;
        };

        plugins =
          [
            "applications"
            "symbols"
            "rink"
            "nix_run"
            "niri_focus"
          ]
          |> map (s: "${config.programs.anyrun.package}/lib/lib${s}.so");
      };

      extraCss = # css
        ''
          /* ===== Color variables ===== */
          :root {
            --bg-color: #313244;
            --fg-color: #cdd6f4;
            --primary-color: #89b4fa;
            --secondary-color: #cba6f7;
            --border-color: var(--primary-color);
            --selected-bg-color: var(--primary-color);
            --selected-fg-color: var(--bg-color);
          }

          /* ===== Global reset ===== */
          * {
            all: unset;
            font-family: "JetBrainsMono Nerd Font", monospace;
          }

          /* ===== Transparent window ===== */
          window {
            background: transparent;
          }

          /* ===== Main container ===== */
          box.main {
            border-radius: 16px;
            background-color: color-mix(in srgb, var(--bg-color) 90%, transparent);
            border: 0.5px solid color-mix(in srgb, var(--fg-color) 25%, transparent);
            padding: 12px; /* add uniform padding around the whole box */
          }

          /* ===== Input field ===== */
          text {
            font-size: 1.3rem;
            background: transparent;
            border: 1px solid var(--border-color);
            border-radius: 16px;
            margin-bottom: 12px;
            padding: 5px 10px;
            min-height: 44px;
            caret-color: var(--primary-color);
          }

          /* ===== List container ===== */
          .matches {
            background-color: transparent;
          }

          /* ===== Single match row ===== */
          .match {
            font-size: 1.1rem;
            padding: 4px 10px; /* tight vertical spacing */
            border-radius: 6px;
          }

          /* Remove default label margins */
          .match * {
            margin: 0;
            padding: 0;
            line-height: 1;
          }

          /* Selected / hover state */
          .match:selected,
          .match:hover {
            background-color: var(--selected-bg-color);
            color: var(--selected-fg-color);
          }

          .match:selected label.plugin.info,
          .match:hover label.plugin.info {
            color: var(--selected-fg-color);
          }

          .match:selected label.match.description,
          .match:hover label.match.description {
            color: color-mix(in srgb, var(--selected-fg-color) 90%, transparent);
          }

          /* ===== Plugin info label ===== */
          label.plugin.info {
            color: var(--fg-color);
            font-size: 1rem;
            min-width: 160px;
            text-align: left;
          }

          /* ===== Description label ===== */
          label.match.description {
            font-size: 0rem;
            color: var(--fg-color);
          }

          /* ===== Fade-in animation ===== */
          @keyframes fade {
            0% {
              opacity: 0;
            }
            100% {
              opacity: 1;
            }
          }
        '';
    };
    kitty.enable = true;
    swaylock.enable = true;

    wlogout = {
      enable = true;
      layout = lib.mkDefault [
        {
          label = "lock";
          action = "${swaylock}";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "${systemctl} hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "logout";
          action = "niri msg action quit";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "${systemctl} poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "${systemctl} suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "${systemctl} reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
    };
  };

  services = {
    blueman-applet.enable = true;
    network-manager-applet.enable = true;

    swayidle.enable = true;
    swaync.enable = true;

    trash.enable = true;

    wpaperd.enable = true;

    wayland-pipewire-idle-inhibit = {
      enable = true;
      # other options can be found here: https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit
    };
  };

  systemd.user.services = {
    blueman-applet = {
      Unit.After = [ "network-manager-applet.service" ];
    };
  };

  home.packages = with pkgs; [
    kanata
    nautilus
    pavucontrol
  ];

  catppuccin.waybar.enable = true;
}
