{inputs, ...}: {
  perSystem = {
    inputs',
    self',
    pkgs,
    ...
  }: {
    packages.mango = let
      config =
        pkgs.writeText "mango.conf"
        # conf
        ''
          exec-once = kitty
          exec-once = wpaperd
        '';
    in
      inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = inputs'.mango.packages.default;

        runtimeInputs = with pkgs; [
          kitty
          self'.packages.wpaperd
        ];

        flags = {
          "-c" = "${config}";
        };
      };
  };
}
