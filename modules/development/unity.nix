{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dev.unity.enable = lib.mkEnableOption "Enables unity hub";
  };

  config = lib.mkIf config.dev.unity.enable {
    users.users.lioma.packages = with pkgs; [
      unityhub
    ];
  };
}
