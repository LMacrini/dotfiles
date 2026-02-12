{
  inputs,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
    toml = pkgs.formats.toml {};
    config = toml.generate "config.toml" {
      any.path = "${self.images}/background.jpg";
    };
  in {
    packages.wpaperd = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.wpaperd;

      flags = {
        "-c" = "${config}";
      };
    };
  };
}
