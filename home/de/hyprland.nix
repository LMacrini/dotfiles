{pkgs, cfg, lib, ...}:
lib.mkIf cfg.de.hyprland.enable {
  home.packages = with pkgs; [
    # waybar
    swaynotificationcenter
    wofi
    # hyprpaper
  ];

  # programs.waybar.enable = true;

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
    settings = {
      "$mod" = "SUPER";

      "exec-once" = "hyprpaper";

      monitor = cfg.de.hyprland.monitor;

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
