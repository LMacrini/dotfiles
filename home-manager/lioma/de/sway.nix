{
  lib,
  cfg,
  ...
}:
lib.mkIf cfg.de.sway.enable {
  home.file = {};
}
