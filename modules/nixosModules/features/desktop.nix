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
          type = types.str;
        };
        package = mkOption {
          default = pkgs.catppuccin-papirus-folders.override {
            accent = "pink";
            flavor = "macchiato";
          };
          type = types.package;
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

        environment.sessionVariables = {
          XCURSOR_THEME = config.cursor.name;
          XCURSOR_SIZE = config.cursor.size;
        };

        rum.misc = {
          gtk = {
            enable = true;

            # probably not necessary
            packages = [
              config.cursor.package
              config.iconTheme.package
              pkgs.adw-gtk3
            ];

            settings = {
              application-prefer-dark-theme = true;
              cursor-theme = config.cursor.name;
              cursor-theme-size = config.cursor.size;
              icon-theme-name = config.iconTheme.name;
              theme-name = "adw-gtk3-dark";
            };
          };
        };
      };
    };
  };
}
