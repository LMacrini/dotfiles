{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    dev.python.enable = lib.mkEnableOption "Enables python";
  };

  config = lib.mkIf config.dev.python.enable {
    environment.systemPackages = with pkgs; [
      python313
    ];
  };
}
