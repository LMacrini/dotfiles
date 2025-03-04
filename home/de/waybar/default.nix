{
  enable = true;
  style = builtins.readFile ./style.css;

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
}
