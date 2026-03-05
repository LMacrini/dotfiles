{
  flake.nixosModules.base = {
    system.nixos = {
      distroId = "seios";
      distroName = "SeiOS";
      vendorId = "seios";
      vendorName = "SeiOS";
    };
  };
}
