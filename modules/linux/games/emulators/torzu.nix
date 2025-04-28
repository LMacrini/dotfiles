{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    games.emulators.torzu.enable = lib.mkEnableOption "Enable emulators";
  };

  config = lib.mkIf config.games.emulators.torzu.enable {
    environment.systemPackages = with pkgs; [
      torzu
    ];
  };
}
