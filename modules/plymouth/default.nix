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
          logo = "${pkgs.my.imgs}/share/logo.png";
          theme = "breeze";
          themePackages = with pkgs; [
            (kdePackages.breeze-plymouth.override {
              logoFile = logo;
              logoName = "miracle-mallet";
              osName = config.system.nixos.distroName;
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

        loader.timeout = lib.mkDefault (
          if config.bootloader == "systemd"
          then 0
          else 1
        );
      })
    ];
  };
}
