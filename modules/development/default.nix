{
  lib,
  config,
  ...
}: {
  imports = [
    ./editors
    ./zig.nix
    ./unity.nix
    ./nix.nix
  ];

  options = {
    dev.enable = lib.mkEnableOption "Enables development tools";
  };

  config = {
    dev.editors.enable = lib.mkDefault config.dev.enable;
    dev.zig.enable = lib.mkDefault true;
    dev.nix.enable = lib.mkDefault config.dev.enable;
    dev.unity.enable = lib.mkDefault false;
  };
}
