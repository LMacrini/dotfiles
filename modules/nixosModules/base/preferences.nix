{lib, ...}: {
  flake.nixosModules.base = with lib; {
    options.preferences = {
      monitors = mkOption {
        default = {};

        type =
          types.attrsOf
          <| types.submodule {
            options = {
              width = mkOption {
                type = types.int;
                example = 1920;
              };

              height = mkOption {
                type = types.int;
                example = 1080;
              };

              refreshRate = mkOption {
                type = types.float;
                example = 144;
              };

              x = mkOption {
                type = types.int;
                default = 0;
              };

              y = mkOption {
                type = types.int;
                default = 0;
              };

              scale = mkOption {
                type = types.float;
                default = 1;
              };

              enabled = mkOption {
                type = types.bool;
                default = true;
              };
            };
          };
      };
    };
  };
}
