{lib, ...}: {
  flake.nixosModules.discord = {pkgs, ...}: let
    userplugins = {
      shyTyping = builtins.fetchGit {
        url = "https://git.nin0.dev/Sqaaakoi-VencordUserPlugins/shyTyping";
        rev = "a6f6a21cf5a64792cb049067b6e3536636fcfa37";
      };
    };

    equicord = pkgs.nur.repos.forkprince.equicord.overrideAttrs (finalAttrs: _: {
      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        pnpm = pkgs.pnpm_10;
        fetcherVersion = 1;
        hash = "sha256-um8CmR4H+sck6sOpIpnISPhYn/rvXNfSn6i/EgQFvk0=";
      };

      preBuild = ''
        mkdir ./src/userplugins
        ${
          userplugins
          |> lib.mapAttrsToList (
            name: value: "cp -r ${value} ./src/userplugins/${name}"
          )
          |> builtins.concatStringsSep "\n"
        }
      '';
    });

    discord = pkgs.discord.override {
      inherit equicord;

      withOpenASAR = true;
      withEquicord = true;
    };
  in {
    nixpkgs.config.allowUnfree = true;

    hjem.users.lioma.packages = [
      discord
    ];
  };
}
