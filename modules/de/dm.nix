{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = with lib; {
    dm = mkOption {
      type =
        types.nullOr
        <| types.enum [
          "gdm"
          "ly"
          "tuigreet"
          # "regreet"
          # "qtgreet"

          # for some reason sddm and lightdm don't work, so i'm leaving them commented out for now
          # "sddm"
          # "lightdm"
        ];
      default = "gdm";
    };
  };

  config =
    let
      inherit (config) dm;
    in
    {
      services = {
        xserver = {
          enable = true;
          xkb = {
            layout = "us";
            variant = "mac";
          };

          displayManager = {
            lightdm.enable = dm == "lightdm";
          };
        };

        displayManager = {
          gdm.enable = dm == "gdm";
          sddm = {
            enable = dm == "sddm";
            wayland.enable = true;
          };
          ly = {
            enable = dm == "ly";
            settings = {
              xinitrc = "null";
            };
          };
        };

        greetd =
          let
            greeters = [
              "regreet"
              "tuigreet"
              "qtgreet"
            ];
          in
          {
            enable = builtins.elem dm greeters;
            settings = {
              default_session.user = "greeter";

              default_session.command =
                let
                  sessionCmd = {
                    gnome = "gnome";
                    hyprland = "hyprland";
                    niri = "niri-session";
                  };
                in
                lib.mkMerge [
                  (lib.mkIf (dm == "tuigreet") (
                    "${lib.getExe pkgs.tuigreet} --cmd ${sessionCmd.${config.de.de}}"
                    + " -trg \"login? :3\" --asterisks --asterisks-char ♥"
                  ))

                  (lib.mkIf (
                    dm == "qtgreet"
                  ) "${lib.getExe pkgs.wayfire} --config ${pkgs.greetd.qtgreet}/etc/qtgreet/wayfire.ini")
                ];
            };
          };
      };

      programs = {
        regreet = {
          enable = dm == "regreet";
        };
      };

      xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };
    };
}
