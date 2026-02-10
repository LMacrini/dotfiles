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

  flake.nixosModules.vmHost = {
    imports = with self.nixosModules; [
      base
    ];

    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    networking.hostName = "vm";
  };
}
