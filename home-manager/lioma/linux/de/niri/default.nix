{pkgs, cfg, config, lib, resources, ...}:
lib.mkIf (cfg.de.de == "niri") {
  programs.niri.settings = let
    fuzzel = {
      hotkey-overlay.title = "Run an Application: fuzzel";
      action.spawn = "fuzzel";
    };
  in {
    binds = with config.lib.niri.actions; {
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

      "Super+Shift+S".action = screenshot;
    } // (
        builtins.listToAttrs (builtins.concatLists (builtins.genList (
          i: let
            ws = i+1;
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
      ));

    clipboard.disable-primary = true;

    hotkey-overlay.skip-at-startup = lib.mkDefault false;

    input = {
      touchpad = {
        dwt = true;
      };
    };

    screenshot-path = "~/Pictures/Screenshots/screenshot-%Y-%m-%d %H-%M-%S.png";

    spawn-at-startup = [
      { command = ["kanata"]; }
      { command = ["waybar"]; }
      { command = ["swww" "img" "${resources}/background.jpg"]; }
    ];

    environment = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };

  programs = {
    fuzzel.enable = true;
    kitty.enable = true;
    waybar = import ./waybar;

    wlogout.enable = true;
  };

  services = {
    swww.enable = true;
  };
  
  # systemd.user.services = {
  #   niri.Unit.Wants = [ "swww.service" ];
  # };

  home.packages = with pkgs; [
    kanata
  ];

  catppuccin.waybar.enable = true;
}
