{lib, pkgs, config, ...}: {
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
      plymouth = {
          inherit (config.plymouth) enable;
        logo = ./logo.png;
        theme = "cross_hud";
        themePackages = with pkgs; [
          adi1090x-plymouth-themes
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

      loader.timeout = 0;
    })
    ];
  };
}
