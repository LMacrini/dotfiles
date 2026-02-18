{self, ...}: {
  flake.nixosModules.general = {pkgs, ...}: {
    imports = with self.nixosModules; [
      discord
    ];

    environment.systemPackages = [
      pkgs.librewolf
    ];
  };
}
