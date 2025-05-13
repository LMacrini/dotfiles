{
  lib,
  config,
  ...
}: {
  options = with lib; {
    bootloader = mkOption {
      default = "systemd";
      type = with types; nullOr (enum [
        "systemd"
        "grub"
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
    };
  };
}
