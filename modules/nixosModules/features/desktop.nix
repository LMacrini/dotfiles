{lib, ...}: {
  flake.aspects.desktop.deps = [
    "hjem"
  ];

  flake.aspects.desktop.module = {
    config,
    pkgs,
    ...
  }: {
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

      services = {
        blueman.enable = true;
      };

      hardware = {
        bluetooth.enable = true;
      };

      programs.dconf.profiles.user.databases = [
        {
          lockAll = true;
          settings."org/gnome/desktop/interface" = {
            accent-color = "pink";
            clock-format = "24h";
            color-scheme = "prefer-dark";
            gtk-theme = "adw-gtk3-dark";

            cursor-size = lib.gvariant.mkInt32 config.cursor.size;
            cursor-theme = config.cursor.name;
            icon-theme = config.iconTheme.name;
          };
        }
      ];

      hjem.users.lioma = let
        # NOTE: possibly extremely unnecessary
        defaultIndexThemePackage = pkgs.writeTextFile {
          name = "index.theme";
          destination = "/share/icons/default/index.theme";
          text = ''
            [Icon Theme]
            Name=Default
            Comment=Default Cursor Theme
            Inherits=${config.cursor.name}
          '';
        };
      in {
        packages = [
          config.cursor.package
          defaultIndexThemePackage
        ];

        environment.sessionVariables = {
          XCURSOR_THEME = config.cursor.name;
          XCURSOR_SIZE = config.cursor.size;
        };

        files = {
          ".icons/default/index.theme".source = "${defaultIndexThemePackage}/share/icons/default/index.theme";
          ".icons/${config.cursor.name}".source = "${config.cursor.package}/share/icons/${config.cursor.name}";
        };

        xdg.data.files = {
          "icons/default/index.theme".source = "${defaultIndexThemePackage}/share/icons/default/index.theme";
          "icons/${config.cursor.name}".source = "${config.cursor.package}/share/icons/${config.cursor.name}";
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
