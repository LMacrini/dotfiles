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
      config,
      ...
    }: {
      imports = [
        inputs.nix-index-database.nixosModules.default
      ];

      environment.systemPackages = with pkgs; [
        prince.helium-nightly # TODO: 26.06 use nixpkgs helium
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
          <Multi_key> <l> <asciitilde> : "ɫ" U026B # LATIN SMALL LETTER L WITH MIDDLE TILDE
          <Multi_key> <asciitilde> <l> : "ɫ" U026B # LATIN SMALL LETTER L WITH MIDDLE TILDE
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

        systemd = let
          mpd = rec {
            dataDir = "${config.hjem.users.lioma.xdg.data.directory}/mpd";
            playlistDir = "${dataDir}/playlists";

            port = 6600;
            address = "127.0.0.1";

            conf = pkgs.writeText "mpd.conf" ''
              playlist_directory "${playlistDir}"
              db_file "${dataDir}/tag_cache"
              state_file "${dataDir}/state"
              sticker_file "${dataDir}/sticker.sql"
              bind_to_address "${address}"

              audio_output {
                type "pipewire"
                name "PipeWire Sound Server"
              }
            '';
          };
        in {
          services = {
            mpd = {
              description = "Music Player Daemon";
              after = [
                "network.target"
                "sound.target"
              ];

              wantedBy = [
                "default.target"
              ];

              restartTriggers = [
                mpd.conf
              ];

              serviceConfig = {
                ExecStart = "${lib.getExe pkgs.mpd} --no-daemon ${mpd.conf}";
                Type = "notify";
                ExecStartPre = ''${lib.getExe' pkgs.coreutils "mkdir"} -p "${mpd.dataDir}" "${mpd.playlistDir}"'';
              };
            };
          };
        };

        packages = with pkgs; [
          mpd
          rmpc
        ];
      };
    };
  };
}
