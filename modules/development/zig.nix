{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    dev.zig.enable = lib.mkEnableOption "Enables zig";
  };

  config = lib.mkIf config.dev.zig.enable {
    environment.systemPackages = with pkgs; [
      zig
    ];
  };
}
