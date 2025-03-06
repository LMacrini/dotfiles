{
  enable = true;
  style = builtins.readFile ./style.css;

  settings = {
    mainbar = {
      margin-top = 10;
      margin-right = 10;
      margin-left = 10;

      modules-left = [ "hyprland/workspaces" "hyprland/window"];
      modules-center = [ "clock" ];
      modules-right = [ 
        "tray"
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

      "hyprland/window" = {
        format = " {title}";
        separate-outputs = true;
      };

      "pulseaudio" = {
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
      };

      "tray" = {
        show-passive-items = true;
        spacing = 10;
      };
    };
  };
}
