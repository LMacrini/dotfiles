{
  self,
  lib,
  ...
}: {
  flake.nixosModules.desktop = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.base
    ];

    options = with lib; {
      cursor = {
        name = mkOption {
          default = "Bibata-Modern-Classic";
          type = types.str;
        };
        size = mkOption {
          default = 24;
          type = types.int;
        };
        package = mkOption {
          default = pkgs.bibata-cursors;
          type = types.package;
        };
      };

      iconTheme = {
        name = mkOption {
          default = "Papirus-Dark";
          package = pkgs.catppuccin-papirus-folders.override {
            accent = "pink";
            flavor = "macchiato";
          };
        };
      };
    };

    config = {
      fonts = {
        packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          nasin-nanpa-helvetica
        ];

        fontconfig.defaultFonts = {
          monospace = [
            "JetBrainsMonoNL NFM"
          ];
        };
      };

      hjem.users.lioma = {
        packages = [
          config.cursor.package
        ];

        rum.misc = {
          gtk = {
            # probably not necessary
            packages = [
              config.cursor.package
              config.iconTheme.package
            ];

            settings = {
              application-prefer-dark-theme = true;
              cursor-theme = config.cursor.name;
              cursor-theme-size = config.cursor.size;
              icon-theme-name = config.iconTheme.name;
            };
          };
        };
      };
    };
  };
}
