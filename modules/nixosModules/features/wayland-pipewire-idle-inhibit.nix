{
  lib,
  self,
  ...
}: {
  flake.aspects.wayland-pipewire-idle-inhibit = {
    deps = ["hjem"];

    module = let
      mod = {
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
            enable = mkEnableOption "wayland pipewire idle inhibit" // {default = true;};

            settings = mkOption {
              type = tomlFormat.type;
              default = {};
            };

            systemdTarget = mkOption {
              type = self.lib.types.systemd.target;
              default = config.wayland.systemd.target;
              defaultText = "config.wayland.systemd.target";
              example = "mango-session.target";
            };
          };
        };

        config = lib.mkIf config.enable {
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
    in {
      hjem.extraModules = [mod];
    };
  };
}
