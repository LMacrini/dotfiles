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

  config = {
    boot.kernelPackages =
      if config.kernel == "default"
      then pkgs.linuxPackages
      else if config.kernel == "latest"
      then pkgs.linuxPackages_latest
      else if config.kernel == "zen"
      then pkgs.linuxPackages_zen
      else builtins.abort "impossible option";
  };
}
