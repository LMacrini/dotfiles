{
  lib,
  config,
  resources,
  ...
}: {
  options = with lib; {
    bootloader = mkOption {
      default = "limine";
      type = with types;
        nullOr (enum [
          "grub"
          "limine"
          "systemd"
        ]);
    };
  };

  config = {
    boot.loader = {
      systemd-boot.enable = config.bootloader == "systemd";
      grub = {
        enable = config.bootloader == "grub";
        efiSupport = true;
        device = "nodev";
      };
      efi = {
        canTouchEfiVariables = true;
      };

      limine = {
        enable = config.bootloader == "limine";
        style = {
          wallpapers = [
            "${resources}/background.jpg"
          ];
          wallpaperStyle = "stretched";
          interface = {
            branding = "WamOS ${config.system.nixos.release}";
            brandingColor = 6; # number from 0-7 that corresponds to:
              # 0: black, 1: red, 2: green, 3: brown, 4: blue, 5: magenta, 6: cyan, 7: gray
          };
        };

        extraConfig = ''
          quiet: ${if config.plymouth.quietBoot then "yes" else "no"}
        '';
      };
    };
  };
}
