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
        "lts"
        "latest"
        "zen"
      ];
    };
  };

  config = let
    kernelMap = with pkgs; {
      lts = linuxPackages;
      latest = linuxPackages_latest;
      zen = linuxPackages_zen;
    };
  in {
    boot.kernelPackages = kernelMap.${config.kernel};
  };
}
