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

      "clock" = {
        format = "{:%F %H:%M}";
        interval = 1;
        tooltip-format = "{:%a %b %d %H:%M:%S %Y}";
      };

      "custom/power" = {
        format = "⏻";
        tooltip = false;
        on-click = "wlogout";
      };

      "hyprland/window" = {
        format = " {title}";
        separate-outputs = true;

        rewrite = {
          "(.*) - YouTube — Ablaze Floorp" = "  $1";
          " NixOS Search - (.*) — Ablaze Floorp" = " 󱄅 $1";
          "(.*) — Ablaze Floorp" = "  $1";
        };
      };

      "pulseaudio" = {
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";

        format = "{icon} {volume}%";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
          default-muted = "󰖁";
          headphone = "󰋋";
          headphone-muted = "󰟎";
          headset = "󰋎";
          headset-muted = "󰋐";
          "alsa_output.usb-SteelSeries_Arctis_Nova_3-00.analog-stereo" = "󰋎";
          "alsa_output.usb-SteelSeries_Arctis_Nova_3-00.analog-stereo-muted" = "󰋐";
        };
      };

      "tray" = {
        show-passive-items = true;
        spacing = 10;
        reverse-direction = true;
      };
    };
  };
}
