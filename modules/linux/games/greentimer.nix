{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    games.greentimer.enable = lib.mkEnableOption "Enables green timer";
  };

  config = lib.mkIf config.games.greentimer.enable {
    users.users.lioma.packages = with pkgs; [
      urn-timer
    ];
  };
}
