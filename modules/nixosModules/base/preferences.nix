{
  lib,
  self,
  ...
}: {
  flake.nixosModules.base = {config, ...}:
    with lib; {
      options.preferences = {
        laptop = {
          enable = mkEnableOption "laptop settings";
        };

        monitors = mkOption {
          default = {};

          type = self.lib.types.monitors;
        };
      };

      config = let
        cfg = config.preferences;
      in {
        services.upower.enable = lib.mkDefault cfg.laptop.enable;
      };
    };
}
