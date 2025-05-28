{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    latestKernel.enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.latestKernel.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems.zfs = lib.mkForce false;
  };
}
