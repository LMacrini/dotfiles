{config, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];
  dev.editors.enable = true;

  networking.hostName = "vm";

  browsers.floorp.enable = false;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  stateVersion = config.system.nixos.release;
}
