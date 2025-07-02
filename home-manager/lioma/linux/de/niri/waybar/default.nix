{
  enable = true;
  style = builtins.readFile ./style.css;

  settings.mainBar = {
    layer = "top";
    position = "bottom";

    modules-left = [ "niri/workspaces" "niri/window" ];
    modules-center = [ "clock" ];
    modules-right = [
      "tray"
      "idle_inhibitor"
      "pulseaudio"
      "battery"
    ];

    "niri/window" = {
      format = " {title}";
      separate-outputs = true;

      rewrite = {
        "(.*) - YouTube — Ablaze Floorp" = "  $1";
        " NixOS Search - (.*) — Ablaze Floorp" = " 󱄅 $1";
        "(.*) — Ablaze Floorp" = "  $1";
      };
    };

    "battery" = {
      format = " {icon} {capacity}% ";
      format-charging = " 󱐋{icon} {capacity}% ";
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

    "idle_inhibitor" = {
      format = " {icon} ";
      format-icons = {
        activated = "";
        deactivated = "";
      };
    };

    "pulseaudio" = {
      on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      on-click-right = "pavucontrol";

      format = " {icon} {volume}% ";
      format-icons = {
        default = ["󰕿" "󰖀" "󰕾"];
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
}
