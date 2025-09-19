{
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    games.standalone.enable = lib.mkEnableOption "Enables standalone games";
  };

  config = lib.mkIf config.games.standalone.enable {
    home-manager.users.lioma.home.packages = with pkgs; [
      my.osu-tachyon
    ];
  };
}
