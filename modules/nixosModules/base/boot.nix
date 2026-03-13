{
  self,
  lib,
  ...
}: {
  flake.nixosModules.base = {
    config,
    pkgs,
    ...
  }: let
    ifPlymouth = lib.mkIf config.boot.plymouth.enable;
  in {
    boot = {
      consoleLogLevel = ifPlymouth 3;
      initrd.verbose = ifPlymouth false;
      kernelParams = ifPlymouth [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];

      loader = {
        efi.canTouchEfiVariables = true;
        timeout = ifPlymouth <| lib.mkDefault 1; # if the bootloader is ever systemd this can be set to 0

        limine = {
          enable = true;

          style = {
            wallpapers = [
              "${self.images}/background.jpg"
            ];
            wallpaperStyle = "stretched";

            interface = {
              branding = "${config.system.nixos.distroName} ${config.system.nixos.release}";
              brandingColor = 6; # number from 0-7 that corresponds to:
              # 0: black, 1: red, 2: green, 3: brown, 4: blue, 5: magenta, 6: cyan, 7: gray
            };
          };

          extraConfig = ifPlymouth ''
            quiet: yes
          '';
        };
      };

      plymouth = rec {
        enable = true;
        logo = "${self.images}/logo.png";
        theme = "breeze";
        themePackages = [
          (pkgs.kdePackages.breeze-plymouth.override {
            logoFile = logo;
            logoName = "miracle-mallet";
            osName = config.system.nixos.distroName;
            osVersion = config.system.nixos.release;
          })
        ];
      };
    };
  };
}
