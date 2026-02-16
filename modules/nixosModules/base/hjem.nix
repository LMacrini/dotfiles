{inputs, ...}: {
  flake.nixosModules.base = {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    hjem = {
      extraModules = [
        inputs.hjem-rum.hjemModules.default
      ];

      users.lioma = {
        enable = true;
        directory = "/home/lioma";
        user = "lioma";
      };

      clobberByDefault = true;
    };
  };
}
