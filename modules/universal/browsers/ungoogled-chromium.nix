{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    browsers.ungoogled-chromium.enable = lib.mkEnableOption "Ungoogled Chromium browser";
  };

  config = lib.mkIf config.browsers.ungoogled-chromium.enable {
    environment.systemPackages = with pkgs; [
      ungoogled-chromium
    ];
  };
}
