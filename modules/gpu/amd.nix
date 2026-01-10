{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    gpu.amd.enable = lib.mkEnableOption "Enables amd gpu";
  };

  config = lib.mkIf config.gpu.amd.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [ rocmPackages.clr.icd ];
    };
  };
}
