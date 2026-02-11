{
  self,
  lib,
  ...
}: {
  flake.nixosModules.mango = {pkgs, ...}: let
    mango = self.packages.${pkgs.stdenv.system}.mango;
  in {
    environment.systemPackages = [
      mango
    ];

    xdg.portal = {
      enable = true;

      config = {
        mango = {
          default = [
            "kde"
          ];

          "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
          "org.freedesktop.impl.portal.ScreenShot" = ["wlr"];
          "org.freedesktop.impl.portal.Inhibit" = [];
        };
      };

      extraPortals = [
        pkgs.kdePackages.xdg-desktop-portal-kde
      ];

      wlr = {
        enable = true;
        settings = {
          screencast = {
            chooser_cmd = "${lib.getExe pkgs.bemenu} -bi";
            chooser_type = "dmenu";
          };
        };
      };

      configPackages = [mango];
    };

    security.polkit.enable = true; # should be on by default but doesn't hurt

    services = {
      displayManager.sessionPackages = [mango];
      graphical-desktop.enable = true;
    };
  };
}
