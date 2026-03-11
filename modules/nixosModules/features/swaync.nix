{lib, ...}: {
  flake.aspects.swaync.deps = ["hjem"];

  flake.aspects.swaync.module = {
    pkgs,
    inputs',
    ...
  }: let
    package = pkgs.swaynotificationcenter;

    conf =
      pkgs.writeText "swaync.json"
      <| builtins.toJSON {
        widgets = [
          "title"
          "dnd"
          "mpris"
          "notifications"
        ];
      };
    style = "${inputs'.catppuccin.packages.swaync}/macchiato.css";

    mod = {config, ...}: {
      packages = [
        package
      ];

      systemd.services.swaync = {
        enable = true;

        description = "Swaync notification daemon";
        documentation = ["https://github.com/ErikReider/SwayNotificationCenter"];
        partOf = [config.wayland.systemd.target];
        after = [config.wayland.systemd.target];
        wantedBy = [config.wayland.systemd.target];

        restartTriggers = [
          conf
          style
        ];

        serviceConfig = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          Restart = "on-failure";
          RestartSec = "5";
          ExecStart = "${lib.getExe package} -c ${conf} -s ${style}";
        };
      };
    };
  in {
    hjem.extraModules = [mod];
  };
}
