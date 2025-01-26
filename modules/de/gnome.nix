{pkgs, lib, config, ...}: {
  options = {
    de.gnome.enable = lib.mkEnableOption "Enable gnome";
  };
  
  config = lib.mkIf config.de.gnome.enable {
    services.xserver.desktopManager.gnome.enable = true;

    environment.gnome.excludePackages = (
      with pkgs;
      [
        gnome-tour
        totem
        geary
        epiphany
        yelp
        gnome-system-monitor
        gnome-software
      ]
    );
  };
}
