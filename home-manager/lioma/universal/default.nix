{
  pkgs,
  lib,
  inputs,
  cfg,
  ...
} @ params: {
  home = {
    packages = with pkgs; [
      blesh
      my.neovim
    ];

    shellAliases = {
      cd = "z";
      lg = "lazygit";
      nix-shell = "nix-shell --run \"${cfg.shell}\"";
    };

    sessionVariables = {
      EDITOR = "nvim";
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

    cava = {
      enable = true;
      settings = {
        output = {
          method = "ncurses";
          orientation = "top";
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };

    floorp = import ./floorp.nix params;

    git = {
      enable = true;
      aliases = {
        co = "checkout";
      };
    };

    kitty = {
      enableGitIntegration = true;
      font = {
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerd-fonts.fira-code;
      };

      shellIntegration = {
        mode = "no-cursor";
      };
    };

    lazygit = {
      enable = true;
    };

    lsd = {
      enable = true;
    };

    starship = {
      enable = true;
      settings = import ./starship.nix;
    };

    zoxide.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        source "$(blesh-share)/ble.sh"
      '';

      shellAliases = {
        grep = "grep --color=auto";
      };
    };

    fish = {
      enable = cfg.shell == "fish";

      interactiveShellInit = ''
        set fish_greeting
      '';
    };

    nushell = {
      enable = cfg.shell == "nu";

      shellAliases = {
        la = "ls -a";
        ll = "ls -l";
        lla = "ls -la";
      };

      settings = {
        show_banner = false;
      };

      extraConfig = ''
        $env.TRANSIENT_PROMPT_COMMAND = {starship module character | $"\n($in)"}
        $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {starship module time}
        def to_command [s: string] {
            mut idx = $s | str index-of " "
            if $idx == -1 {
                $idx = $s | str length
            }
            let first = $s | str substring 0..($idx - 1)
            let rest = $s | str substring ($idx + 1)..
            [$first $rest]
        }

        def lor [
          c1: string
          c2: string
        ] {
            let cmd1 = to_command $c1
            let cmd2 = to_command $c2
            if (^$cmd1.0 $cmd1.1 | complete | get exit_code) != 0 {
                ^$cmd2.0 $cmd2.1
            }
        }

        def land [
          c1: string
          c2: string
        ] {
            let cmd1 = to_command $c1
            let cmd2 = to_command $c2
            if (^$cmd1.0 $cmd1.1 | complete | get exit_code) == 0 {
                ^$cmd2.0 $cmd2.1
            }
        }
      '';
    };

    zsh = {
      enable = cfg.shell == "zsh";

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
        '';
      in
        lib.mkMerge [
          after
        ];
    };

    home-manager.enable = true;
  };
}
