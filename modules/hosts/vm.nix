{inputs, self, ...}: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    imports = with self.nixosModule; [
      base
    ];

    networking.hostName = "vm";
  };
}
