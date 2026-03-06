{
  inputs,
  lib,
  self,
  ...
}: {
  flake.aspects.hjem.module = {
    config,
    pkgs,
    ...
  }: let
    home = config.hjem.users.lioma.directory;
    dirs = {
      DOCUMENTS = "${home}/Documents";
      DOWNLOAD = "${home}/Downloads";
      GAMES = "${home}/Games";
      MUSIC = "${home}/Music";
      PICTURES = "${home}/Pictures";
      PROJECTS = "${home}/Projects";
      PUBLICSHARE = "${home}/Public";
      VIDEOS = "${home}/Videos";
    };

    bindings = lib.mapAttrs' (k: lib.nameValuePair "XDG_${k}_DIR") dirs;
  in {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    systemd.services.createXdgUserDirectories = let
      directoriesList = lib.attrValues dirs;
      mkdir = dir: "[[ -L ${dir} ]] || mkdir -p ${dir}";
    in {
      after = [
        "hjem-activate@lioma.service"
      ];
      partOf = ["hjem.target"];
      wantedBy = ["hjem.target"];

      script = lib.concatMapStringsSep "\n" mkdir directoriesList;
    };

    hjem = let
      mod = {
        options = with lib; {
          wayland.systemd.target = mkOption {
            type = self.lib.types.systemd.target;
            default = "graphical-session.target";
          };

          configDirectory = mkOption {
            type = types.str;
          };
        };
      };
    in {
      extraModules = [
        inputs.hjem-rum.hjemModules.default
        mod
      ];

      users.lioma = let
        cfg = config.hjem.users.lioma;
      in {
        enable = true;
        directory = "/home/lioma";
        configDirectory = "${cfg.directory}/seiconf";
        user = "lioma";

        rum.environment.hideWarning = true;

        files.".profile" = {
          executable = true;
          source = config.hjem.users.lioma.environment.loadEnv;
        };

        packages = [
          pkgs.xdg-user-dirs
        ];

        environment.sessionVariables =
          bindings
          // {
            NH_FLAKE = cfg.configDirectory;
          };

        xdg.config.files = {
          "user-dirs.dirs" = {
            generator = lib.generators.toKeyValue {};
            value = builtins.mapAttrs (_: value: ''"${value}"'') bindings;
          };

          "user-dirs.conf".text = "enabled=False";

          "fish/conf.d/hjem-environment.fish" = lib.mkIf (cfg.environment.sessionVariables != {}) {
            text =
              lib.concatMapAttrsStringSep "\n" (
                name: value: "set -gx ${lib.escapeShellArg name} ${lib.escapeShellArg (toString value)}"
              )
              cfg.environment.sessionVariables;
          };
        };
      };

      clobberByDefault = true;
    };
  };
}
