{
  cfg,
  pkgs,
  lib,
  os,
  ...
} @ params: let
  addons = import ./firefox-addons params;
in {
  enable = lib.mkDefault cfg.browsers.floorp.enable;

  enableGnomeExtensions =
    if os == "linux"
    then cfg.de.de == "gnome"
    else false;

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
            name = "Nix";
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
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };

          nix-options = {
            name = "Nix Options";
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };

          twint-search = {
            name = "Twint Search";
            urls = [
              {
                template = "https://search.twint.my.id/search?q={searchTerms}";
              }
            ];
            definedAliases = ["@tw"];
          };

          "bing@search.mozilla.orgdefault".metaData.hidden = true;
          "startpage@search.mozilla.orgdefault".metaData.hidden = true;
          "you.com@search.mozilla.orgdefault".metaData.hidden = true;
        };
      };

      extensions = {
        force = true;
        packages = with addons; [
          bitwarden-password-manager
          bonjourr-startpage
          catppuccin-macchiato-pink
          darkreader
          dearrow
          decentraleyes
          indie-wiki-buddy
          nekocap
          return-youtube-dislikes
          simple-tab-groups
          sponsorblock
          styl-us
          traduzir-paginas-web
          ublock-origin
          youtube-anti-translate
          youtube-tweaks
        ];
        settings = {
          "uBlock0@raymondhill.net".settings = {
            selectedFiltersLists = [
              "user-filters"
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
              "ublock-quick-fixes"
              "easylist"
              "easyprivacy"
              "urlhaus-1"
              "plowe-0"
            ];
          };
        };
      };

      settings = {
        "extensions.autoDisableScopes" = 0;
        "floorp.browser.sidebar.enable" = false;
        "floorp.browser.workspaces.enabled" = false;
        "userChrome.hidden.urlbar_iconbox" = true;
      };
    };
  };
}
