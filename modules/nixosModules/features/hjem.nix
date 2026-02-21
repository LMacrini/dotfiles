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
      mkdir = dir: ''[[ -L ${dir} ]] || mkdir -p ${dir}'';
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
            type = types.strMatching "[a-zA-Z0-9@%:_.\\-]+[.]target";
            default = "graphical-session.target";
          };
        };
      };
    in {
      extraModules = [
        inputs.hjem-rum.hjemModules.default
        mod
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
