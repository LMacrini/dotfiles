{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services = {
    displayManager.sddm.enable = lib.mkDefault (!config.de.gnome.enable);
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "mac";
      };

      displayManager.gdm.enable = lib.mkDefault config.de.gnome.enable;
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
