{pkgs, cfg, lib, ...}:
lib.mkIf cfg.de.hyprland.enable {
  home.packages = with pkgs; [
    swaynotificationcenter
    wofi
  ];

  programs = {
    wlogout.enable = true;
    waybar = {
      enable = true;
      settings = {
        mainbar = {
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ 
            "custom/power"
          ];

          "hyprland/workspaces" = {
            all-outputs = true;
          };

          "custom/power" = {
            format = " ⏻ ";
            tooltip = false;
            on-click = "wlogout";
          };
        };
      };
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

      "exec-once" = [
        "hyprpaper"
        "waybar"
      ];

      monitor = cfg.de.hyprland.monitor 
        ++ [
        ", preffered, auto, 1"
      ];

      env = [
        "HYPRCURSOR_THEME,catppuccin-macchiato-dark-cursors"
        "HYPRCURSOR_SIZE,32"
        "XCURSOR_THEME,catppuccin-macchiato-dark-cursors"
        "XCURSOR_THEME,32"
      ];

      bind = [
        "$mod, T, exec, wofi --show drun"
        "$mod, Q, exec, ghostty"
        "$mod, C, killactive"
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
    };
  };
}
