{
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    config =
      pkgs.writeText "config.fish"
      # fish
      ''
        ${lib.getExe pkgs.nix-your-shell} fish | source
        ${lib.getExe pkgs.zoxide} init fish | source
        ${lib.getExe pkgs.direnv} hook fish | source
      '';
  in {
    packages.fish = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      runtimeInputs = with pkgs; [
        zoxide
      ];

      flags = {
        "-C" = "source ${config}";
      };
    };
  };
}
