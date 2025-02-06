{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    browsers.floorp.enable = lib.mkEnableOption "Enables the Floorp browser";
  };

  config = lib.mkIf config.browsers.floorp.enable {
    environment.systemPackages = with pkgs; [
      floorp
    ];
  };
}
