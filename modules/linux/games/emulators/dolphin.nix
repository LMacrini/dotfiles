{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    games.emulators.dolphin.enable = lib.mkEnableOption "Enable Dolphin";
  };

  config = lib.mkIf config.games.emulators.dolphin.enable {
    environment.systemPackages = with pkgs; [
      unstable.dolphin-emu
    ];
  };
}
