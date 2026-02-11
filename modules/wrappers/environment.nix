{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.environment = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = self'.packages.fish;

      runtimeInputs = [
        self'.packages.nh

        pkgs.git

        self'.packages.helix
      ];

      env = {
        EDITOR = lib.getExe self'.packages.helix;
      };
    };
  };
}
