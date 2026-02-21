{lib, ...}: {
  flake.aspects.wayland-pipewire-idle-inhibit = {
    deps = ["hjem"];

    module = {
      pkgs,
      config,
      ...
    }: let
      cfg = config.lioma.services.wayland-pipewire-idle-inhibit;

      tomlFormat = pkgs.formats.toml {};
      settings = tomlFormat.generate "wayland-pipewire-idle-inhibit.toml" cfg.settings;
    in {
      options = with lib; {
        lioma.services.wayland-pipewire-idle-inhibit = {
          settings = mkOption {
            type = tomlFormat.type;
            default = {};
          };

          systemdTarget = mkOption {
            type = types.str;
            default = config.hjem.users.lioma.wayland.systemd.target;
            defaultText = "config.hjem.users.lioma.wayland.systemd.target";
            example = "mango-session.target";
          };
        };
      };

      config.hjem.users.lioma.systemd.services.wayland-pipewire-idle-inhibit = {
        description = "Inhibit Wayland idling when media is played through pipewire";
        documentation = ["https://github.com/rafaelrc7/wayland-pipewire-idle-inhibit"];
        after = [
          "pipewire.service"
          cfg.systemdTarget
        ];
        wants = ["pipewire.service"];
        wantedBy = [cfg.systemdTarget];

        script = "${lib.getExe pkgs.wayland-pipewire-idle-inhibit} -c ${settings}";

        serviceConfig = {
          Restart = "always";
          RestartSec = 10;
        };
      };
    };
  };
}
