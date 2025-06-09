{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.de.de == "gnome") {
    services = {
      gnome = {
        gnome-browser-connector.enable = true;
      };
      xserver.desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      totem
      geary
      epiphany
      yelp
      gnome-system-monitor
      gnome-software
    ];

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
      gnomeExtensions.quick-settings-audio-panel
      gnomeExtensions.quick-settings-tweaker

      ghostty
    ];
  };
}
