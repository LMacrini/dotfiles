{
  lib,
  self,
  ...
}: {
  flake.nixosModules.base = with lib; {
    options.preferences = {
      monitors = mkOption {
        default = {};

        type = self.lib.types.monitors;
      };
    };
  };
}
