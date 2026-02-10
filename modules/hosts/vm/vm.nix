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

      inputs.disko.nixosModules.disko
      self.diskoConfigurations.vm
    ];

    networking.hostName = "vm";
  };
}
