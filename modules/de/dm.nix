{config, pkgs, ...}: {
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "mac";
    };

    displayManager = 
      if config.de.gnome.enable == true then
        {gdm.enable = true;}
      else
        {lightdm.enable = true;};
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
