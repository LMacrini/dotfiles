{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  package = inputs.mango.packages.${pkgs.stdenv.system}.mango.override {
    enableXWayland = false;
  };
in
{
  config = lib.mkIf (config.de.de == "mango") {
    environment.systemPackages = [ package ];
    programs.xwayland.enable = false;
    security.polkit.enable = true;

    services = {
      displayManager.sessionPackages = [ package ];

      graphical-desktop.enable = true;
    };

    security.pam.services = {
      swaylock = { };
      noctalia = { };
    };
  };
}
