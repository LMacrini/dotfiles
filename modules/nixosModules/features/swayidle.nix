{lib, ...}: {
  flake.aspects.swayidle = {
    deps = ["hjem"];

    module = {
      config,
      pkgs,
      ...
    }: let
      mod = {config, ...}: let
        cfg = config.services.swayidle;
      in {
        options.services.swayidle = with lib; let
          timeoutModule = {
            options = {
              timeout = mkOption {
                type = types.ints.positive;
                example = 60;
                description = "Timeout in seconds.";
              };

              command = mkOption {
                type = types.str;
                description = "Command to run after timeout seconds of inactivity.";
              };

              resumeCommand = mkOption {
                type = with types; nullOr str;
                default = null;
                description = "Command to run when there is activity again.";
              };
            };
          };

          eventModule = {
            options = {
              event = mkOption {
                type = types.enum [
                  "before-sleep"
                  "after-resume"
                  "lock"
                  "unlock"
                ];
                description = "Event name.";
              };

              command = mkOption {
                type = types.str;
                description = "Command to run when event occurs.";
              };
            };
          };
        in {
          enable = lib.mkEnableOption "idle manager for Wayland";

          package = lib.mkPackageOption pkgs "swayidle" {};

          timeouts = mkOption {
            type = with types; listOf (submodule timeoutModule);
            default = [];
            example = literalExpression ''
              [
                { timeout = 60; command = "''${pkgs.swaylock}/bin/swaylock -fF"; }
                { timeout = 90; command = "''${pkgs.systemd}/bin/systemctl suspend"; }
              ]
            '';
            description = "List of commands to run after idle timeout.";
          };

          events = mkOption {
            type = with types; listOf (submodule eventModule);
            default = [];
            example = literalExpression ''
              [
                { event = "before-sleep"; command = "''${pkgs.swaylock}/bin/swaylock -fF"; }
                { event = "lock"; command = "lock"; }
              ]
            '';
            description = "Run command on occurrence of a event.";
          };

          extraArgs = mkOption {
            type = with types; listOf str;
            default = ["-w"];
            description = "Extra arguments to pass to swayidle.";
          };

          systemdTarget = mkOption {
            type = types.str;
            default = config.wayland.systemd.target;
            defaultText = literalExpression "config.wayland.systemd.target";
            example = "sway-session.target";
            description = ''
              Systemd target to bind to.
            '';
          };
        };

        config = lib.mkIf cfg.enable {
          systemd.services.swayidle = {
            description = "Idle manager for Wayland";
            documentation = ["man:swayidle(1)"];
            after = [cfg.systemdTarget];
            partOf = [cfg.systemdTarget];
            wantedBy = [cfg.systemdTarget];

            script = let
              mkTimeout = t:
                [
                  "timeout"
                  (toString t.timeout)
                  t.command
                ]
                ++ lib.optionals (t.resumeCommand != null) [
                  "resume"
                  t.resumeCommand
                ];

              mkEvent = e: [
                e.event
                e.command
              ];

              args =
                cfg.extraArgs ++ (lib.concatMap mkTimeout cfg.timeouts) ++ (lib.concatMap mkEvent cfg.events);
            in "${lib.getExe cfg.package} ${lib.escapeShellArgs args}";

            serviceConfig = {
              Type = "simple";
              Restart = "always";
            };

            unitConfig = {
              ConditionEnvironment = "WAYLAND_DISPLAY";
            };
          };
        };
      };
    in {
      hjem = {
        extraModules = [mod];
        users.lioma.services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 150;
              command = "${lib.getExe pkgs.brightnessctl} -s set 10";
              resumeCommand = "${lib.getExe pkgs.brightnessctl} -r";
            }
            {
              timeout = 300;
              command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
            }
            {
              timeout =
                if (config.preferences.laptop.enable)
                then 420
                else 900;
              command = "${lib.getExe' pkgs.systemd "systemctl"} suspend";
            }
          ];
        };
      };
    };
  };
}
