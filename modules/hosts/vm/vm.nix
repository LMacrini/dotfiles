{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.vmHost
    ];
  };

  flake.nixosModules.vmHost = {config, ...}: {
    imports = [
      self.nixosModules.mango
    ];

    kanata.enable = false;

    # services.desktopManager.plasma6.enable = true;
    # services.displayManager.sddm = {
    #   enable = true;
    #   wayland.enable = true;
    # };

    networking.hostName = "vm";

    system.stateVersion = config.system.nixos.release;
  };
}
