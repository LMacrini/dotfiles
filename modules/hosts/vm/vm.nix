{self, ...}: {
  flake.nixosConfigurations.vm = self.lib.nixosSystem {
    module = self.nixosModules.vmHost;
  };

  flake.nixosModules.vmHost = {config, ...}: {
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    networking.hostName = "vm";

    system.stateVersion = config.system.nixos.release;
  };
}
