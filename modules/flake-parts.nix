{lib, ...}: {
  options = with lib; {
    flake = {
      aspects = mkOption {
        type =
          types.lazyAttrsOf
          <| types.submodule {
            options = {
              deps = mkOption {
                default = [];
                type = types.listOf types.str;
              };

              module = mkOption {
                type = types.deferredModule;
              };
            };
          };
      };

      hjemModules = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = {};
      };
    };
  };

  config = {
    systems = [
      "x86_64-linux"
    ];
  };
}
