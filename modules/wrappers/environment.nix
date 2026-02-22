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
        pkgs.nix
        pkgs.nix-inspect
        pkgs.nix-output-monitor
        self'.packages.nh

        pkgs.bat
        pkgs.git
        pkgs.ripgrep

        self'.packages.helix
        self'.packages.jujutsu
        self'.packages.qalc
      ];

      env = {
        EDITOR = lib.getExe self'.packages.helix;
      };
    };
  };
}
