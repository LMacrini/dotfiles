{lib, ...}: {
  flake.nixosModules.base = {
    time.timeZone = lib.mkDefault "America/Toronto";
    i18n.defaultLocale = "en_CA.UTF-8";
  };
}
