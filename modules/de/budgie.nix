{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.de.de == "budgie") {
    services.xserver.desktopManager.budgie.enable = true;

    environment.budgie.excludePackages = with pkgs; [
      mate.mate-terminal
      vlc
    ];
  };
}
