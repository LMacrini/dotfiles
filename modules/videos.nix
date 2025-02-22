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
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vaapi
        obs-nvfbc
        droidcam-obs
        obs-vkcapture
        obs-gstreamer
        input-overlay
        obs-multi-rtmp
        obs-source-clone
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

    environment.systemPackages = with pkgs; [
    ];
  };
}
