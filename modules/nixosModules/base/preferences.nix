{
  lib,
  self,
  ...
}: {
  flake.nixosModules.base = with lib; {
    options.preferences = {
      laptop = {
        enable = mkEnableOption "laptop settings";
      };

      monitors = mkOption {
        default = {};

        type = self.lib.types.monitors;
      };
    };
  };
}
