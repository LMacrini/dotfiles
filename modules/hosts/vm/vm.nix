{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.vm_host
    ];
  };

  flake.nixosModules.vm_host = {
    imports = with self.nixosModules; [
      base
    ];

    networking.hostName = "vm";
  };
}
