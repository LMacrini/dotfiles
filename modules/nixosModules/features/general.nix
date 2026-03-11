{
  lib,
  inputs,
  ...
}: {
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
      imports = [
        inputs.nix-index-database.nixosModules.default
      ];

      programs = {
        nix-index-database.comma.enable = true;
        steam.package = lib.mkDefault inputs'.millennium.packages.millennium-steam;
      };

      hjem.users.lioma = {
        environment.sessionVariables = {
          COMMA_CACHING = 0; # i want it to ask me every time
        };

        files.".XCompose".text = ''
          include "%L"

          <Multi_key> <q> <e> <d> : "∎" U250E # END OF PROOF
        '';

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
