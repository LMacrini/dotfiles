{lib, ...}: {
  flake.aspects.general = {
    deps = [
      "discord"
      "browser"
      "hjem"
    ];

    module = {
      pkgs,
      inputs',
      ...
    }: {
      programs = {
        steam.package = lib.mkDefault inputs'.millennium.packages.millennium-steam;
      };

      hjem.users.lioma = {
        rum.programs.direnv.enable = true;
        xdg.config.files."direnv/direnv.toml" = let
          tomlFormat = pkgs.formats.toml {};
        in {
          source = tomlFormat.generate "direnv.toml" {
            global = {
              log_format = "-";
              log_filter = "^$";
              warn_timeout = "0s";
            };
          };
        };
      };
    };
  };
}
