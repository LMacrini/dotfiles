{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.lionels-laptop = inputs.nixkpgs.lib.nixosSystem {
    modules = [
      self.nixosModules.lionels-laptop
    ];
  };

  flake.nixosModules.lionels-laptop = {
    imports = with self.nixosModules; [
      base
    ];

    networking.hostName = "lionels-laptop";

    system.stateVersion = "25.11";
  };
}
