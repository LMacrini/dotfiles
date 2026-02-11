{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    themeConfig = builtins.readFile "${inputs'.catppuccin.packages.fish}/Catppuccin Macchiato.theme";
    match = builtins.split "(fish_color_.*?)$" themeConfig;
    themeConfs = builtins.elemAt (builtins.elemAt match 1) 0;
    lines = lib.splitString "\n" themeConfs |> builtins.map (s: "set -g ${s}");

    config =
      pkgs.writeText "config.fish"
      # fish
      ''
        ${builtins.concatStringsSep "\n" lines}

        status is-interactive; and begin
          ${lib.getExe pkgs.nix-your-shell} fish | source
          ${lib.getExe pkgs.zoxide} init fish | source
          ${lib.getExe pkgs.direnv} hook fish | source

          alias cd z

          set fish_greeting
        end
      '';
  in {
    packages.fish = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      runtimeInputs = with pkgs; [
        direnv
        zoxide
      ];

      flags = {
        "-C" = "source ${config}";
      };
    };
  };
}
