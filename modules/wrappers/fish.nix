{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    inputs',
    system,
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

          function fish_command_not_found
            set program $argv[1]

            if not test -f /etc/programs.sqlite
              echo "$program: command not found" >&2
              return
            end

            set packages (sqlite3 /etc/programs.sqlite "select package from programs where name = \"$program\" and system = \"${system}\";")

            if test (count $packages) -eq 0
              echo "$program: command not found in PATH or in nixpkgs"
              return
            else if test (count $packages) -eq 1
              echo "The program '$program' is not in your PATH. You can make it available in an" >&2
              echo "ephemeral shell by using the following package from nixpkgs:" >&2
              echo "  $packages[1]"
              return
            end

            echo "The program '$program' is not in your PATH. It is provided by several packages." >&2
            echo "You can make it available in an ephemeral shell by using one of the following" >&2
            echo "packages from nixpkgs:" >&2
            for package in $packages
              echo "  $package" >&2
            end
          end

          if type -q direnv
            direnv hook fish | source
          end

          if set -q KITTY_INSTALLATION_DIR
            set --global KITTY_SHELL_INTEGRATION "no-rc no-cursor"
            source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
            set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
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
        sqlite
        zoxide
      ];

      flags = {
        "-C" = "source ${config}";
      };
    };
  };
}
