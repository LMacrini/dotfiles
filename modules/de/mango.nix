{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.de.de == "mango") {
    programs.mango = {
      enable = true;
      package = inputs.mango.packages.${pkgs.stdenv.system}.mango.override {
        enableXWayland = false;
      };
    };
    programs.xwayland.enable = false;

    security.pam.services = {
      swaylock = {
        enable = true;
      };
    };
  };
}
