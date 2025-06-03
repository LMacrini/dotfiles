{cfg, pkgs, ...}: {
  enable = cfg.browsers.floorp.enable;

  enableGnomeExtensions = cfg.de.gnome.enable;

  languagePacks = [
    "en-CA"
    "fr"
  ];

  policies = {
    # see https://mozilla.github.io/policy-templates/

    # BlockAboutConfig = true # for the future!!
    DefaultDownloadDirectory = "\${home}/Downloads";
  };

  profiles = {
    "Wam :3" = {
      bookmarks = {
        force = true;
        settings = [
          {
            name = "test";
            toolbar = true;
            bookmarks = [
              {
                name = "NixOS search";
                url = "https://search.nixos.org";
              }
            ];
          }
        ];
      };

      search = {
        force = true;
        
        default = "twint-search";

        order = [
          "twint-search"
          "ddg@search.mozilla.orgdefault"
          "google@search.mozilla.orgdefault"
        ];

        engines = {
          nixpkgs = {
            name = "Nix Packages";
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          nix-options = {
            name = "Nix Options";
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          twint-search = {
            name = "Twint Search";
            urls = [{
              template = "https://search.twint.my.id/search?q={searchTerms}";
            }];
            definedAliases = [ "@tw" ];
          };

          "bing@search.mozilla.orgdefault".metaData.hidden = true;
          "startpage@search.mozilla.orgdefault".metaData.hidden = true;
          "you.com@search.mozilla.orgdefault".metaData.hidden = true;
        };
      };
    };
  };
}
