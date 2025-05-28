{
  pkgs,
  lib,
  ...
}: {
  home = {
    packages = with pkgs; [
      blesh
    ];

    shellAliases = {
      cd = "z";
      lg = "lazygit";
    };

    sessionVariables = {
      DO_NOT_TRACK = 1;
    };

    file = {
      ".blerc" = {
        source = ./home/.blerc;
      };
    };
  };

  programs = {
    carapace = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = true;
      enableZshIntegration = false;
    };

    direnv.enable = true;

    starship = {
      enable = true;
      settings = import ./starship.nix;
    };

    zoxide.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        source "$(blesh-share)/ble.sh"

        cls () {
          line=0
          while [ $line -lt $((LINES-2)) ]; do
            echo ""
          done
        }

        if [ $SHLVL -eq 1 ]; then
          cls
        fi
      '';

      shellAliases = {
        ls = "lsd";
        la = "lsd -a";
        ll = "lsd -l";
        lla = "lsd -la";
        grep = "grep --color=auto";
      };
    };

    nushell = {
      enable = true;

      shellAliases = {
        la = "ls -a";
        ll = "ls -l";
        lla = "ls -la";
      };

      settings = {
        show_banner = false;
      };

      extraConfig = ''
        $env.TRANSIENT_PROMPT_COMMAND = {starship module character}
        $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {starship module time}
        def cls [] {
          clear
          for _ in 2..(term size).rows { print "" }
        }
        if $env.SHLVL == 1 {cls}
      '';
    };

    zsh = {
      enable = true;

      shellAliases = {
        ls = "lsd";
        la = "lsd -a";
        ll = "lsd -l";
        lla = "lsd -la";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
      };
      antidote = {
        enable = true;
        plugins = [
          "zsh-users/zsh-autosuggestions"
          "zsh-users/zsh-syntax-highlighting"
        ];
      };

      initContent = let
        # Common order values:
        # 500 (mkBefore): Early initialization (replaces initExtraFirst)
        #
        # 550: Before completion initialization (replaces initExtraBeforeCompInit)
        #
        # 1000 (default): General configuration (replaces initExtra)
        #
        # 1500 (mkAfter): Last to run configuration

        after = lib.mkOrder 1500 ''
          transient-prompt () {
            PROMPT=$(starship module character) zle .reset-prompt
          }

          autoload -Uz add-zle-hook-widget
          add-zle-hook-widget zle-line-finish transient-prompt

          cls () {
            clear
            print -n ''${(pl:$LINES::\n:):-}
          }

          if [ $SHLVL -eq 1 ]; then
            cls
          fi
        '';
      in
        lib.mkMerge [
          after
        ];
    };

    home-manager.enable = true;
  };
}
