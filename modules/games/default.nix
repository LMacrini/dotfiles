{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./games.nix
    ./launchers.nix
    ./light-games.nix
    ./tools.nix
    ./greentimer.nix
  ];

  options = {
    games.enable = lib.mkEnableOption "Enables games";
  };

  config = {
    games.standalone.enable = lib.mkDefault config.games.enable;
    games.launchers.enable = lib.mkDefault config.games.enable;
    games.light.enable = lib.mkDefault config.games.enable;

    games.tools.enable = lib.mkDefault config.games.launchers.enable;

    games.greentimer.enable = lib.mkDefault (
      config.games.standalone.enable || config.games.launchers.enable || config.games.light.enable
    );
  };

}
