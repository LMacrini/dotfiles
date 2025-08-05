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
    users.users.lioma.packages = with pkgs; [
      (gaming.osu-lazer-bin.override {
        releaseStream = "tachyon";
      })
    ];
  };
}
