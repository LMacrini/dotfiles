{
  lib,
  config,
  ...
}: {
  imports = [
    ./editors
    ./unity.nix
  ];

  options = {
    dev.enable = lib.mkEnableOption "Enables development tools";
  };

  config = {
    dev.editors.enable = lib.mkDefault config.dev.enable;
    dev.unity.enable = lib.mkDefault false;
  };
}
