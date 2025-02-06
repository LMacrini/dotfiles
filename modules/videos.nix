{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    videos.enable = lib.mkEnableOption "Enable video tools";
  };

  config = lib.mkIf config.videos.enable {
    environment.systemPackages = with pkgs; [
      obs-studio
      davinci-resolve
    ];
  };
}
