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

    environment.systemPackages = with pkgs; [
      rose-pine-icon-theme
      papirus-icon-theme
      adw-gtk3
      gnome-tweaks
      gnomeExtensions.blur-my-shell
      gnomeExtensions.rounded-window-corners-reborn
      gnomeExtensions.user-themes
      gnomeExtensions.caffeine
      gnomeExtensions.gnome-40-ui-improvements
      gnomeExtensions.just-perfection
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnomeExtensions.arcmenu
    ];
  };
}
