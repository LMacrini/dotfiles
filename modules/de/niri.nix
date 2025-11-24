{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  config = lib.mkIf (config.de.de == "niri") {
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri-stable;

    # seems to fix wlogout icons
    # see: https://discourse.nixos.org/t/help-loadin-svgs-in-gtk-css/65542
    programs.gdk-pixbuf.modulePackages = [
      pkgs.librsvg
    ];

    nixpkgs.overlays = [
      inputs.niri.overlays.niri
    ];
  };
}
