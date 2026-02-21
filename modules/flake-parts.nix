{lib, ...}: {
  options = with lib; {
    flake.aspects = mkOption {
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
  };

  config = {
    systems = [
      "x86_64-linux"
    ];
  };
}
