{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    appimages.enable = lib.mkEnableOption "Enables appimages support";
  };

  config = lib.mkIf config.appimages.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    environment.systemPackages = with pkgs; [
      gearlever
    ];
  };
}
