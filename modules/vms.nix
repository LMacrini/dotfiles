{ config, lib, ... }:
{
  options = {
    vms.enable = lib.mkEnableOption "Enable virtual machines";
  };

  config = lib.mkIf config.vms.enable {
    users.users.lioma.extraGroups = [ "libvirtd" ];
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
