{
  self,
  lib,
  ...
}: {
  flake.nixosModules.mango = {
    pkgs,
    config,
    ...
  }: let
    mango =
      (self.wrapperModules.mango.apply {
        inherit pkgs;
        inherit (config.preferences) monitors;
      }).wrapper;
  in {
    imports = [
      self.nixosModules.desktop
    ];

    environment.systemPackages = [
      mango
      pkgs.kitty
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

    # systemd.user.services.monitors = {
    #   after = ["graphical-session.target"];
    #   description = "Configure monitors";

    #   serviceConfig = {
    #     Type = "simple";
    #   };

    #   script =
    #     lib.mapAttrsToList (name: conf: "${lib.getExe pkgs.wlr-randr} --output ${name} --mode ${toString conf.width}x${toString conf.height}@${toString conf.refreshRate} --pos ${toString conf.x},${toString conf.y} --scale ${toString conf.scale}") config.preferences.monitors
    #     |> builtins.concatStringsSep "\n";

    #   wantedBy = ["graphical-session.target"];
    # };
  };
}
