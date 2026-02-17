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

          set fish_greeting

          if type -q direnv
            direnv hook fish | source
          end
        end
      '';
  in {
    packages.fish = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      runtimeInputs = with pkgs; [
        lsd
        nix-your-shell
        zoxide
      ];

      preHook = ''
        tmp=$(mktemp -d)
        CONFIG=$XDG_CONFIG_HOME
        XDG_CONFIG_HOME=$tmp
        mkdir "$tmp"/fish
        export __fish_initialized=999999
      '';

      flags = {
        "-C" = [
          "set -gx XDG_CONFIG_HOME $CONFIG"
          "source ${config}"
          "fish -Nc \"sleep 2; rm -r $tmp\" &"
        ];
      };
    };
  };
}
