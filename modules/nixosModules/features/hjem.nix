{inputs, ...}: {
  flake.aspects.hjem.module = {config, ...}: {
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

        rum.environment.hideWarning = true;

        files.".profile" = {
          executable = true;
          source = config.hjem.users.lioma.environment.loadEnv;
        };
      };

      clobberByDefault = true;
    };
  };
}
