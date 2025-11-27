{config, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];
  networking.hostName = "vm";

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  de.de = "gnome";

  stateVersion = config.system.nixos.release;
}
