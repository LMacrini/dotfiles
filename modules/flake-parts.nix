{
  lib,
  self,
  ...
}: {
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

    flake.nixosModules = lib.mapAttrs' (k: v:
      lib.nameValuePair
      ("_" + k)
      {
        imports =
          [
            v.module
          ]
          ++ self.lib.aspects v.deps;
      })
    self.aspects;
  };
}
