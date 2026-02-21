{
  inputs,
  lib,
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
      mkdir = dir: ''[[ -L ${dir} ]] || run mkdir -p $VERBOSE_ARG ${dir}'';
    in {
      after = [
        "hjem-activate@lioma.service"
      ];
      requires = [
        "hjem-activate@lioma.service"
      ];

      restartTriggers = [
        directoriesList
      ];

      script = lib.concatMapStringsSep "\n" mkdir directoriesList;
    };

    hjem = {
      extraModules = [
        inputs.hjem-rum.hjemModules.default
      ];

      users.lioma = {
        enable = true;
        directory = "/home/lioma";
        user = "lioma";

        rum.environment.hideWarning = true;

        files.".profile" = {
          executable = true;
          source = config.hjem.users.lioma.environment.loadEnv;
        };

        packages = [
          pkgs.xdg-user-dirs
        ];

        environment.sessionVariables = bindings;

        xdg.config.files = {
          "user-dirs.dirs" = {
            generator = lib.generators.toKeyValue {};
            value = builtins.mapAttrs (_: value: ''"${value}"'') bindings;
          };

          "user-dirs.conf".text = "enabled=False";
        };
      };

      clobberByDefault = true;
    };
  };
}
