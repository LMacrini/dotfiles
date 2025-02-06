{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    de.budgie.enable = lib.mkEnableOption "Enable budgie";
  };

  config = lib.mkIf config.de.budgie.enable {
    services.xserver.desktopManager.budgie.enable = true;

    environment.budgie.excludePackages = with pkgs; [
      mate.mate-terminal
      vlc
    ];
  };
}
