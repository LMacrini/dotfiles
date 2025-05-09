{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    games.launchers.enable = lib.mkEnableOption "Enables game launchers";
  };

  config = lib.mkIf config.games.launchers.enable {
    programs.steam.enable = true;

    users.users.lioma.packages = with pkgs; [
      wine
      prismlauncher
      heroic
      unstable.lutris
      protonplus
    ];

    services.flatpak = {
      packages = [
        "io.github.everestapi.Olympus"
        "org.vinegarhq.Sober"
        # "net.lutris.Lutris"
      ];
    };
  };
}
