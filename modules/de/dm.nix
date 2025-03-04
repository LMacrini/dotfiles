{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "mac";
      };

      displayManager.gdm.enable = lib.mkDefault true;
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
