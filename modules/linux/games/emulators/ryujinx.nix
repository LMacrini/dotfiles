{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    games.emulators.ryujinx.enable = lib.mkEnableOption "Enable emulators";
  };

  config = lib.mkIf config.games.emulators.ryujinx.enable {
    environment.systemPackages = with pkgs; [
      unstable.ryujinx-greemdev
    ];
  };
}
