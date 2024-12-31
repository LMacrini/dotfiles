{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    games.launchers.enable = lib.mkEnableOption "Enables game launchers";
  };

  config = lib.mkIf config.games.launchers.enable {
    programs.steam.enable = true;

    users.users.lioma.packages = with pkgs; [
      unstable.lutris
      wine
      prismlauncher
      heroic
    ];

    services.flatpak = {
      packages = [
        {
          flatpakref = "https://sober.vinegarhq.org/sober.flatpakref";
          sha256 = "1pj8y1xhiwgbnhrr3yr3ybpfis9slrl73i0b1lc9q89vhip6ym2l";
        }
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
      ];
    };
  };
}
