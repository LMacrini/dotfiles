{inputs, ...}: {
  flake.nixosModules.base = {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    hjem.users.lioma = {
      enable = true;
      directory = "/home/lioma";
      user = "lioma";
    };
  };
}
