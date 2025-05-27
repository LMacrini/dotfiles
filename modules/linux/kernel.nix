{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    latestKernel.enable = lib.mkOption {
      default = true;
      example = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.latestKernel.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems.zfs = lib.mkForce false;
  };
}
