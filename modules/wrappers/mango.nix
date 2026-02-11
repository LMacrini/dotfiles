{inputs, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    packages.mango = let
      config =
        pkgs.writeText "mango.conf"
        # conf
        ''
          exec-once = kitty
        '';
    in
      inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = inputs'.mango.packages.default;

        runtimeInputs = with pkgs; [
          kitty
        ];

        flags = {
          "-c" = "${config}";
        };
      };
  };
}
