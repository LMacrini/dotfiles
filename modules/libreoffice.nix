{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    libreoffice.enable = lib.mkEnableOption "Enable libreoffice";
  };

  config = lib.mkIf config.libreoffice.enable {
    environment.systemPackages = with pkgs; [
      libreoffice-still
    ];
  };
}
