{ ... }:
{
  imports = [
    ../../modules
  ];

  networking.hostName = "Virtual-Machine";

  browsers.floorp.enable = false;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
