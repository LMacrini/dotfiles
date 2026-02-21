{
  flake.nixosModules.base = {
    system.nixos = {
      distroId = "seios";
      distroName = "SeiOS";
      vendorId = "seios";
      vendorName = "SeiOS";
    };

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
