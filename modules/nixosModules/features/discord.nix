{
  flake.nixosModules.discord = {pkgs, ...}: let
    userplugins = {
      shyTyping = builtins.fetchGit {
        url = "https://git.nin0.dev/Sqaaakoi-VencordUserPlugins/shyTyping";
        rev = "a6f6a21cf5a64792cb049067b6e3536636fcfa37";
      };
    };

    equicord = pkgs.equicord.overrideAttrs (finalAttrs: _: {
      version = "v1.14.2.0";
      src = pkgs.fetchFromGitHub {
        owner = "Equicord";
        repo = "Equicord";
        tag = finalAttrs.version;
      };

      preBuild = ''
        mkdir ./src/userplugins
        ${userplugins
          |> builtins.mapAttrs (
            name: value: "cp -r ${value} ./src/userplugins/${name}"
          )}
      '';
    });

    discord = pkgs.discord.override {
      inherit equicord;

      withOpenAsar = true;
      withEquicord = true;
    };
  in {
    environment.systemPackages = [discord];
  };
}
