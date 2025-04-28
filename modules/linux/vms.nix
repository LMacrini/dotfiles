{
  config,
  lib,
  ...
}: {
  options = {
    vms.enable = lib.mkEnableOption "Enable virtual machines";
  };

  config = lib.mkIf config.vms.enable {
    services.flatpak.packages = [
      "org.gnome.Boxes"
    ];
  };
}
