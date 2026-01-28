{ cfg, ... }:
{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;

    settings.mainBar = {
      layer = "top";
      position = "top";

      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];

      "niri/window" = {
        format = "  {title}";
        separate-outputs = true;

        rewrite = {
          " (.*) - YouTube — LibreWolf" = "   $1";
          "  NixOS Search - (.*) — LibreWolf" = "  󱄅 $1";
          " (.*) — LibreWolf" = "   $1";
        };
      };

      "niri/workspaces" = {
        format = "{icon}";
      };
    };
  };
}
