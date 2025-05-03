{
  lib,
  config,
  ...
}: {
  imports = [
    ./editors
    ./unity.nix
  ];

  options = with lib; {
    dev.enable = mkOption {
      default = true;
      type = types.bool;
      description = "Whether to enable dev options";
    };
  };

  config = {
    dev.editors.enable = lib.mkDefault config.dev.enable;
    dev.unity.enable = lib.mkDefault false;
  };
}
