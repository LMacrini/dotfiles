{lib, ...}: {
  flake.hjemModules.wayland-pipewire-idle-inhibit = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.services.wayland-pipewire-idle-inhibit;

    tomlFormat = pkgs.formats.toml {};
    settings = tomlFormat.generate "wayland-pipewire-idle-inhibit.toml" cfg.settings;
  in {
    options = with lib; {
      services.wayland-pipewire-idle-inhibit = {
        enable = mkEnableOption "wayland pipewire idle inhibit";
        settings = mkOption {
          type = tomlFormat.type;
          default = {};
        };

        systemdTarget = mkOption {
          type = types.str;
          default = "graphical-session.target";
          example = "mango-session.target";
        };
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.services.wayland-pipewire-idle-inhibit = {
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
