{inputs, ...}: {
  flake.nixosModules.hjem = {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    hjem.users.lioma.enable = true;
  };
}
