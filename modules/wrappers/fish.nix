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
          direnv hook fish | source
          nix-your-shell fish | source
          zoxide init fish | source

          alias cd z
          alias ls lsd
          alias ll "lsd -l"
          alias la "lsd -A"
          alias lt "lsd --tree"
          alias lla "lsd -lA"
          alias llt "lsd -l --tree"

          set fish_greeting
        end
      '';
  in {
    packages.fish = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      runtimeInputs = with pkgs; [
        direnv
        lsd
        nix-your-shell
        zoxide
      ];

      flags = {
        "-C" = "source ${config}";
        "-N" = true;
      };
    };
  };
}
