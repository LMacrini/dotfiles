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
  };
}
