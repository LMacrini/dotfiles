{lib, config, ...}: {
  config = lib.mkIf (config.de.de == "niri") {
    programs.niri.enable = true;
  };
}
