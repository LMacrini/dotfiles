{pkgs, lib, config, ...}:
{
  options = {
    latestKernel.enable = lib.mkOption {
      default = !config.gpu.nvidia.enable;
      example = true;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.latestKernel.enable {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.supportedFilesystems.zfs = lib.mkForce false;
  };
}
