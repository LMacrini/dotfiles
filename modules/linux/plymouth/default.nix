{
  lib,
  pkgs,
  config,
  ...
}: {
  options = with lib; {
    plymouth = {
      enable = mkOption {
        default = true;
        type = types.bool;
      };
      quietBoot = mkOption {
        default = true;
        type = types.bool;
      };
    };
  };
  config = {
    boot = lib.mkMerge [
      {
        plymouth = rec {
          inherit (config.plymouth) enable;
          logo = ./logo.png;
          theme = "breeze";
          themePackages = with pkgs; [
            (plasma5Packages.breeze-plymouth.override {
              logoFile = logo;
              logoName = "miracle-mallet";
              osName = "WamOS";
              osVersion = config.system.nixos.release;
            })
          ];
        };
      }

      (lib.mkIf config.plymouth.quietBoot {
        consoleLogLevel = 3;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];

        loader.timeout = lib.mkDefault 0;
      })
    ];
  };
}
