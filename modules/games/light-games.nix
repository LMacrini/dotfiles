{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    games.light.enable = lib.mkEnableOption "Enables light games";
  };

  config = lib.mkIf config.games.light.enable {
    users.users.lioma.packages = with pkgs; [
      aaaaxy
    ];
  };
}
