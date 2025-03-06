{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    dm = lib.mkOption {
      type = lib.types.enum [
        "gdm"
        "ly"
        # for some reason sddm and lightdm don't work, so i'm leaving them commented out for now
        # "sddm"
        # "lightdm"
      ];
      default = "gdm";
    };
  };

  config = let
    inherit (config) dm;
  in {
    services = {
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "mac";
        };

        displayManager = {
          gdm.enable = dm == "gdm";
          lightdm.enable = dm == "lightdm";
        };
      };

      displayManager = {
        sddm = {
          enable = dm == "sddm";
          wayland.enable = true;
        };
        ly.enable = dm == "ly";
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
