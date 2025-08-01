{
  enable = true;
  style = builtins.readFile ./style.css;

  settings.mainBar = {
    layer = "top";
    position = "top";

    modules-left = ["niri/workspaces" "niri/window"];
    modules-center = ["clock"];
    modules-right = [
      "tray"
      "idle_inhibitor"
      "custom/notification"
      "pulseaudio"
      "battery"
    ];

    "niri/window" = {
      format = "  {title}";
      separate-outputs = true;

      rewrite = {
        " (.*) - YouTube — Ablaze Floorp" = "   $1";
        "  NixOS Search - (.*) — Ablaze Floorp" = "  󱄅 $1";
        " (.*) — Ablaze Floorp" = "   $1";
      };
    };

    "niri/workspaces" = {
      format = "{icon}";
      format-icons = {
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

    "custom/notification" = {
      tooltip = false;
      format = " {icon} ";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "swaync-client -d -sw";
      on-click-right = "swaync-client -t -sw";
      escape = true;
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
