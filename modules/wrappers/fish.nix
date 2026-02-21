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
    match =
      builtins.readFile "${inputs'.catppuccin.packages.fish}/Catppuccin Macchiato.theme"
      |> builtins.split "(fish_color_.*?)$";

    theme =
      builtins.elemAt (builtins.elemAt match 1) 0
      |> lib.splitString "\n"
      |> builtins.map (s: "set -g ${s}")
      |> builtins.concatStringsSep "\n";

    config =
      pkgs.writeText "config.fish"
      # fish
      ''
        ${theme}

        status is-interactive; and begin
          nix-your-shell fish | source
          zoxide init fish | source

          alias cd z
          alias ls lsd
          alias ll "lsd -l"
          alias la "lsd -A"
          alias lt "lsd --tree"
          alias lla "lsd -lA"
          alias llt "lsd -l --tree"
          alias l "lsd -alh"

          set fish_greeting

          if type -q direnv
            direnv hook fish | source
          end
        end
      '';

    unwrapped = pkgs.fish;
  in {
    packages.fish = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = unwrapped;
      runtimeInputs = with pkgs; [
        lsd
        nix-your-shell
        zoxide
      ];

      flags = {
        "-C" = "source ${config}";
      };
    };
  };
}
