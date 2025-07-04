{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  config = lib.mkIf (config.de.de == "niri") {
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri-unstable;

    nixpkgs.overlays = [
      inputs.niri.overlays.niri
    ];
  };
}
