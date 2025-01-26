{config, pkgs, ...}: {
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services = {
    displayManager.sddm.enable = !config.de.gnome.enable;
      xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "mac";
      };

      displayManager.gdm.enable = config.de.gnome.enable;
    };
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
