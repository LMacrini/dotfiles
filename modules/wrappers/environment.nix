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
        pkgs.nixd
        pkgs.nh
        self'.formatter

        pkgs.git
        pkgs.bat
        pkgs.ripgrep
        pkgs.tlrc
        pkgs.rip2
        pkgs.p7zip
        pkgs.unzip
        pkgs.ffmpeg

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
