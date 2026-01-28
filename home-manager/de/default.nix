{
  cfg,
  lib,
  ...
}:
{
  imports =
    lib.optional (cfg.de.de == "hyprland") ./hyprland
    ++ lib.optional (cfg.de.de == "niri") ./niri
    ++ lib.optional (cfg.de.de == "mango") ./mango;
}
