{inputs, ...}: {
  flake.wrapperModules.waybar = inputs.wrappers.wrapperModules.waybar.apply {
    settings = {
      modules-center = ["clock"];
      modules-right = [
        "tray"
        "idle_inhibitor"
        "power-profiles-daemon"
        "custom/notification"
        "pulseaudio"
        "battery"
      ];

      battery = {
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

      clock = {
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

      idle_inhibitor = {
        format = " {icon} ";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };

      power-profiles-daemon = {
        format = " {icon} ";
        # tooltip-format = "Power profile: {profile}\nDriver: {driver}";
        tooltip-format = ''
          Power profile: {profile}
          Driver: {driver}'';

        tooltip = true;
        format-icons = {
          default = "";
          performance = "";
          balanced = "";
          power-saver = "";
        };
      };

      pulseaudio = {
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";

        format = " {icon} {volume}% ";
        format-icons = {
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
          default-muted = "󰖁";
          headphone = "󰋋";
          headphone-muted = "󰟎";
          headset = "󰋎";
          headset-muted = "󰋐";
          "alsa_output.usb-SteelSeries_Arctis_Nova_3-00.analog-stereo" = "󰋎";
          "alsa_output.usb-SteelSeries_Arctis_Nova_3-00.analog-stereo-muted" = "󰋐";
        };
      };

      tray = {
        show-passive-items = true;
        spacing = 10;
        reverse-direction = true;
        sort-by-app-id = true;
      };
    };
  };
}
