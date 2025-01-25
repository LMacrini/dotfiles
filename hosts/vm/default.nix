{ ... }:
{
  imports = [
    ../../modules
    ./hardware-configuration.nix
  ];

  networking.hostName = "vm";

  browsers.floorp.enable = false;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
