{self, ...}: {
  flake.nixosModules.general = {
    imports = [
      self.nixosModules.discord
    ];
  };
}
