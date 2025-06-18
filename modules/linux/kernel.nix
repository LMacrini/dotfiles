{
  pkgs,
  lib,
  config,
  ...
}: {
  options = with lib; {
    kernel = mkOption {
      default = "zen";
      example = "latest";
      type = types.enum [
        "default"
        "latest"
        "zen"
      ];
    };
  };

  config = let
    kernelMap = with pkgs; {
      default = linuxPackages;
      latest = linuxPackages_latest;
      zen = linuxPackages_zen;
    };
  in {
    boot.kernelPackages = kernelMap.${config.kernel};
  };
}
