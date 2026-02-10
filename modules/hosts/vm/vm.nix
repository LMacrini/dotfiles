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

    networking.hostName = "vm";
  };
}
