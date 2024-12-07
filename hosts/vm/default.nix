{ ... }:
{
  imports = [
    ../../modules
  ];

  networking.hostName = "Virtual-Machine";

  browsers.floorp.enable = false;
}
