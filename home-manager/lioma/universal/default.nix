{
  pkgs,
  lib,
  cfg,
  config,
  ...
} @ params: {
  accounts = {
    email = {
      accounts = {
        Personal = {
          address = "liomacrini@gmail.com";
          flavor = "gmail.com";
          primary = true;
          realName = "Lionel Macrini";

          thunderbird = {
            enable = true;
          };
        };
      };
      maildirBasePath = "Mail";
    };
  };

  home = {
    shellAliases = {
      cd = "z";
      cls = "clear";
      nix-shell = "nix-shell --run \"${cfg.shell}\"";
    };

    sessionVariables = {
      EDITOR = "hx";
    };

    file = {
      ".blerc" = {
        source = ./home/.blerc;
      };
    };

    packages = with pkgs; [
      bitwarden-desktop
      (unstable.equibop.override {electron = electron_36;})
      keymapp
    ];
  };

  services = {
    mpd = {
      enable = true;
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

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        unstable.nil # NOTE: can probably use stable in 25.11, unstable is mostly for pipe operators
      ];

      settings = {
        editor = {
          cursor-shape = {
            insert = "block";
            normal = "block";
            select = "underline";
          };

          end-of-line-diagnostics = "hint";

          inline-diagnostics = {
            other-lines = "error";
          };

          line-number = "relative";
          mouse = false;
          soft-wrap.enable = true;
        };

        keys = {
          insert = {
            up = "no_op";
            down = "no_op";
            left = "no_op";
            right = "no_op";
            pageup = "no_op";
            pagedown = "no_op";
            home = "no_op";
            end = "no_op";
          };
        };
      };
      # NOTE: i am really mad, i think the way that helix works makes the generated toml not work properly
      # languages = {
      #   language = [
      #     {
      #       name = "nix";
      #       auto-format = true;
      #       formatter = {
      #         command = "nix";
      #         args = ["fmt"];
      #       };
      #     }

      #     {
      #       name = "zig";
      #       auto-format = false;
      #     }
      #   ];
      # };
    };
  };

  # HACK: don't use the helix module directly because it doesn't work, see above note
  xdg.configFile."helix/languages.toml".text =
    # toml
    ''
      [[language]]
      name = "nix"
      auto-format = true
      formatter = {command = "nix", args = ["fmt"]}

      [[language]]
      name = "zig"
      auto-format = false
    '';

  programs = {
    jujutsu = {
      enable = true;

      settings = {
        aliases = {
          tug = ["bookmark" "move" "main" "--from" "heads(::@- & bookmarks())" "--to" "@-"];
          tugb = ["bookmark" "move" "--to" "@-"];
        };

        user = {
          email = "liomacrini@gmail.com";
          name = "LMacrini";
        };

        ui = {
          default-command = "log";
          diff-editor = ":builtin";
          paginate = "never";
        };
      };
    };

    kitty = {
      enableGitIntegration = true;
      font = {
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerd-fonts.fira-code;
      };

      keybindings = {
        "kitty_mod+t" = "no_op";
      };

      shellIntegration = {
        mode = "no-cursor";
      };

      settings = {
        enable_audio_bell = false;

        shell = "zellij -l welcome";
      };
    };

    lsd = {
      enable = true;
    };

    rmpc = {
      enable = true;
    };

    starship = {
      enable = true;
      enableTransience = true;
      settings = import ./starship.nix;
    };

    thunderbird = {
      enable = true;

      profiles = {
        default = {
          accountsOrder = [
            "Personal"
          ];
          isDefault = true;
        };
      };
    };

    zellij = {
      enable = true;

      # TODO: revisit in 25.11, this shouldn't be required
      inherit
        (config.home.shell)
        enableBashIntegration
        enableFishIntegration
        enableZshIntegration
        ;

      settings = {
        copy_on_select = false;
        show_startup_tips = false;
        support_kitty_keyboard_protocol = false; # HACK: remove this line when helix updates crossterm to v0.29.0 or later
      };
    };

    zoxide.enable = true;

    bash = {
      enable = true;
      initExtra =
        # bash
        ''
          source "${pkgs.blesh}/share/blesh/ble.sh"
        '';

      shellAliases = {
        grep = "grep --color=auto";
      };
    };

    fish = {
      enable = cfg.shell == "fish";

      functions = {
        starship_transient_prompt_func =
          # fish
          ''
            starship module line_break
            starship module character
          '';
        starship_transient_rprompt_func =
          # fish
          ''
            starship module time
          '';
        touchp =
          # fish
          ''
            mkdir -p (dirname $argv[1])
            touch $argv[1]
          '';
      };

      interactiveShellInit = with config.programs; # fish
      
        ''
          set fish_greeting
        ''
        + lib.optionalString (zellij.enable && zellij.enableFishIntegration) # fish
        
        ''
          eval (${lib.getExe zellij.package} setup --generate-completion fish | string collect)
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

      extraConfig =
        # nu
        ''
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
        # NOTE: Common order values:
        # 500 (mkBefore): Early initialization (replaces initExtraFirst)
        #
        # 550: Before completion initialization (replaces initExtraBeforeCompInit)
        #
        # 1000 (default): General configuration (replaces initExtra)
        #
        # 1500 (mkAfter): Last to run configuration
        after =
          lib.mkOrder 1500 # zsh
          
          ''
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
