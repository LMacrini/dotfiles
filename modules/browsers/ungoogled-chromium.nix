{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    browsers.ungoogled-chromium.enable = lib.mkEnableOption "Enables the Ungoogled Chromium browser";
  };

  config = lib.mkIf config.browsers.floorp.enable {
    environment.systemPackages = with pkgs; [
      ungoogled-chromium
    ];
  };
}
