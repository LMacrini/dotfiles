{pkgs, ...}: {
  programs.niri.settings.input.touchpad.scroll-factor = 0.25;

  services.flatpak.packages = [
    "org.gnome.Boxes"
  ];
}
