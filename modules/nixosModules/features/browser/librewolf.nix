{lib, ...}: {
  flake.aspects.browser.deps = [
    "hjem"
  ];

  flake.aspects.browser.module = {pkgs, ...}: let
    package = pkgs.librewolf;

    userPrefValue = pref:
      builtins.toJSON (
        if lib.isBool pref || lib.isInt pref || lib.isString pref
        then pref
        else builtins.toJSON pref
      );

    mkUserJs = prefs:
      prefs
      |> lib.mapAttrsToList (name: value: ''user_pref("${name}", ${userPrefValue value});'')
      |> builtins.concatStringsSep "\n";

    buildMozillaXpiAddon = lib.makeOverridable (
      {
        stdenv ? pkgs.stdenvNoCC,
        fetchurl ? pkgs.fetchurl,
        pname,
        version,
        addonId,
        url,
        sha256,
        meta,
        ...
      }:
        stdenv.mkDerivation {
          name = "${pname}-${version}";

          inherit meta;

          src = fetchurl {inherit url sha256;};

          preferLocalBuild = true;
          allowSubstitutes = true;

          passthru = {inherit addonId;};

          buildCommand = ''
            dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
            mkdir -p "$dst"
            install -v -m644 "$src" "$dst/${addonId}.xpi"
          '';
        }
    );

    generatedAddons = import ./_generated-addons.nix {
      inherit buildMozillaXpiAddon;
      inherit (pkgs) fetchurl lib;
      stdenv = pkgs.stdenvNoCC;
    };

    addons = generatedAddons;
  in {
    hjem.users.lioma = {
      packages = [package];

      files = {
        ".librewolf/profiles.ini" = {
          generator = lib.generators.toINI {};
          value = {
            Profile0 = {
              Name = "default";
              Path = "default";
              IsRelative = 1;
              Default = 1;
            };

            General = {
              StartWithLastProfile = 1;
              Version = 2;
            };
          };
        };

        ".librewolf/default/user.js".text = mkUserJs {
          "extensions.autoDisableScopes" = 0;
          "general.autoScroll" = true;
          "image.jxl.enabled" = true;
          "middlemouse.paste" = false;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };

        ".librewolf/default/chrome/userChrome.css".text =
          # css
          ''
            #identity-box {
              display: none;
            }
          '';

        ".librewolf/default/extensions" = {
          source = let
            # The extensions path shared by all profiles; will not be supported
            # by future browser versions.
            # NOTE: check home-manager at modules/programs/firefox/mkFirefoxModule.nix
            # if this breaks
            extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";

            extensionsEnv = pkgs.buildEnv {
              name = "firefox-extensions";
              paths = with addons; [
                bitwarden-password-manager
                bonjourr-startpage
                canvasblocker
                catppuccin-macchiato-pink
                dearrow
                refined-github-
                simple-tab-groups
                sponsorblock
                ublock-origin
              ];
            };
          in "${extensionsEnv}/share/mozilla/${extensionPath}";
        };
      };
    };
  };
}
