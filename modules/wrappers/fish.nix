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
          atuin init fish | source
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
        atuin
        lsd
        nix-your-shell
        zoxide
      ];

      preHook = ''
        CONFIG=$XDG_CONFIG_HOME
        XDG_CONFIG_HOME=/tmp/fish_conf
        mkdir -p /tmp/fish_conf/fish
        export __fish_initialized=3800
      '';

      flags = {
        "-C" = [
          "set -x XDG_CONFIG_HOME $CONFIG"
          "source ${config}"
        ];
      };
    };
  };
}
