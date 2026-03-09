{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    catppuccin = inputs'.catppuccin.packages.wlogout;
    style = pkgs.writeText "style.css" ''
      @import url("${catppuccin}/themes/macchiato/pink.css");

      ${lib.concatMapStrings (icon:
          # css
          ''
            #${icon} {
              background-image: url("${catppuccin}/icons/wlogout/macchiato/pink/${icon}.svg");
            }
          '')
        [
          "hibernate"
          "lock"
          "logout"
          "reboot"
          "shutdown"
          "suspend"
        ]}
    '';

    layout =
      pkgs.writeText "layout"
      <| builtins.toJSON [
        {
          label = "lock";
          action = "loginctl lock-session";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
  in {
    packages.wlogout = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.wlogout;

      runtimeInputs = [
        pkgs.systemd
      ];

      flags = {
        # "--layout" = "${layout}";
        "--css" = "${style}";
      };
    };
  };
}
