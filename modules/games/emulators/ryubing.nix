{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    games.emulators.ryubing.enable = lib.mkEnableOption "Enable emulators";
  };

  config = lib.mkIf config.games.emulators.ryubing.enable {
    environment.systemPackages = with pkgs; [
      ryubing
    ];
  };
}
