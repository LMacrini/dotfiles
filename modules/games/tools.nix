{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    games.tools.enable = lib.mkEnableOption "Enables game tools";
  };

  config = lib.mkIf config.games.tools.enable {
    users.users.lioma.packages = with pkgs; [
      blockbench
      protontricks
    ];
  };
}
