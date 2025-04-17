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
        {
          appId = "moe.launcher.an-anime-game-launcher";
          origin = "launcher.moe";
        }
        {
          appId = "moe.launcher.the-honkers-railway-launcher";
          origin = "launcher.moe";
        }
        {
          appId = "moe.launcher.honkers-launcher";
          origin = "launcher.moe";
        }
        {
          appId = "moe.launcher.sleepy-launcher";
          origin = "launcher.moe";
        }
        "io.github.everestapi.Olympus"
        "org.vinegarhq.Sober"
        # "net.lutris.Lutris"
      ];
    };
  };
}
