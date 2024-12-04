{config, lib, pks, ...}:{

  options = {
    libreoffice.enable = mkEnableOption "Enable libreoffice";
  };

  config = lib.mkIf config.libreoffice.enable {
    environment.systemPackages = with pkgs; [
      libreoffice-still
      hunspell
      hunspellDicts.en_CA
      hunspellDicts.fr-any
    ];
  };
}
