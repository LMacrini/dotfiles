{self, ...}: {
  flake.nixosModules.general = {
    imports = with self.nixosModules; [
      discord
      helium
    ];
  };
}
