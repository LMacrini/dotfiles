{
  pkgs,
  lib,
  cfg,
  config,
  inputs,
  ...
} @ params: {
  imports = [
    ./options.nix
    inputs.moonlight.homeModules.default
  ];

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

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 4;
        indent_style = "space";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
      };

      "*.{md,txt}" = {
        indent_size = 8;
        indent_style = "tabs";
      };

      "*.{nix,hs,json,jsonc,json5,yaml,toml}" = {
        indent_size = 2;
      };
    };
  };

  fonts.fontconfig = {
    enable = true;
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

    packages = with pkgs;
      lib.mkIf config.guiApps [
        bitwarden-desktop
        (discord.override {
          moonlight = inputs.moonlight.packages.${system}.moonlight;
          withOpenASAR = true;
          withMoonlight = true;
        })
        # (unstable.equibop.override {electron = electron_36;})
        keymapp
      ];
  };

  services = {
    mpd = {
      enable = true;
    };
  };

  programs = {
    bat = {
      enable = true;

      extraPackages = with pkgs.bat-extras; [
        batgrep
        batman
      ];
    };

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
      config = {
        warn_timeout = "0s";
      };
    };

    floorp = import ./floorp.nix params;

    git = {
      enable = true;
      aliases = {
        co = "checkout";
      };
      extraConfig = {
        credential = {
          helper = "store";
        };
      };
    };

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        marksman
        unstable.nil # NOTE: can probably use stable in 25.11, unstable is mostly for pipe operators
      ];

      settings = {
        editor = {
          cursor-shape = {
            insert = "block";
            normal = "block";
            select = "underline";
          };

          line-number = "relative";
          mouse = false;
          soft-wrap.enable = true;
        };

        keys =
          lib.recursiveUpdate {
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
          } (lib.optionalAttrs (config.programs.kitty.enable || config.programs.ghostty.enable) {
            normal = {
              tab = "move_parent_node_end";
              S-tab = "move_parent_node_start";
            };

            insert = {
              S-tab = "move_parent_node_start";
            };

            select = {
              tab = "extend_parent_node_end";
              S-tab = "extend_parent_node_start";
            };
          });
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

      [[language]]
      name = "javascript"
      formatter = { command = 'prettier', args = ["--parser", "typescript"] }
      auto-format = true

      [[language]]
      name = "python"
      language-servers = ["ty", "ruff", "basedpyright", "jedi", "pylsp"]

      [[language]]
      name = "typescript"
      formatter = { command = 'prettier', args = ["--parser", "typescript"] }
      auto-format = true

      [[language]]
      name = "tsx"
      formatter = { command = 'prettier', args = ["--parser", "typescript"] }
      auto-format = true

      [language-server.zls.config]
      enable_snippets = false

      [[language]]
      name = "haskell"
      formatter = { command = 'fourmolu', args = ["--stdin-input-file", "."] }
      auto-format = true
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

      keybindings =
        {
          "kitty_mod+enter" = "launch --cwd=current";
        }
        // lib.optionalAttrs (config.programs.tmux.enable || config.programs.zellij.enable) {
          "kitty_mod+t" = "no_op";
          "kitty_mod+enter" = "no_op";
        };

      shellIntegration = {
        mode = "no-cursor";
      };

      settings = {
        confirm_os_window_close = 0;

        cursor_trail = 1;

        enable_audio_bell = false;

        # shell = "zellij -l welcome";
      };
    };

    lsd = {
      enable = true;
    };

    moonlight = {
      enable = config.guiApps;
      configs.stable = {
        repositories = [
          "https://moonlight-mod.github.io/extensions-dist/repo.json"
          "https://lare354.github.io/moonlight-plugins/repo.json"
        ];
        extensions = {
          allActivities.enabled = true;
          ownerCrown.enabled = true;
          antinonce.enabled = true;
          betterCodeblocks.enabled = true;
          betterTags.enabled = true;
          betterUploadButton.enabled = true;
          betterYoutubeEmbeds.enabled = true;
          callIdling.enabled = true;
          cleanChatBar = {
            enabled = true;
            config = {
              removedButtons = [
                "gift"
                "gif"
                "sticker"
                "activity"
              ];
            };
          };
          clearUrls.enabled = true;
          colorConsistency.enabled = true;
          copyAvatarUrl.enabled = true;
          copyWebP.enabled = true;
          moonlight-css = {
            enabled = true;
            config = {
              paths = [
                "https://catppuccin.github.io/discord/dist/catppuccin-macchiato-pink.theme.css"
              ];
              themeAttributes = true;
            };
          }; # TODO: figure this out
          customSearchEngine = {
            enabled = true;
            config = {
              label = "Search with Twint";
              url = "https://search.twint.my.id/s?q=%s";
            };
          };
          decor.enabled = true;
          disableSentry.enabled = true;
          domOptimizer.enabled = true;
          doubleClickActions.enabled = true;
          doubleClickToJoin.enabled = true;
          favoriteGifSearch.enabled = true;
          freeScreenShare.enabled = true;
          freeStickers.enabled = true;
          freemoji.enabled = true;
          gameActivityToggle.enabled = true;
          httpCats.enabled = true;
          imageViewer.enabled = true;
          inviteToNowhere.enabled = true;
          jumpToBlocked.enabled = true;
          katex.enabled = true;
          manyAccounts.enabled = true;
          mediaTweaks.enabled = true;
          modPlayer.enabled = true;
          moonbase.enabled = true;
          nameColor = {
            enabled = true;
            config.colorize = "None";
          };
          nativeFixes = {
            enabled = true;
            config = {
              linuxAutroscroll = true;
              vulkan = true;
              waylandExplicitSync = true;
              zeroCopy = true;
            };
          };
          neatSettingsContextMenu.enabled = true;
          noHelp.enabled = true;
          noReplyChainNag.enabled = true;
          noTrack.enabled = true;
          popoutDates.enabled = true;
          questCompleter.enabled = true;
          quietLoggers.enabled = true;
          remindMe.enabled = true;
          replyChain.enabled = true;
          roleColoredMessages = {
            enabled = true;
            config.pastelize = true;
          };
          spotifySpoof.enabled = true;
          streamQualityWorkaround.enabled = true; # TODO: figure out if i want this
          svgEmbed.enabled = true;
          typingTweaks = {
            enabled = true;
            config = {
              alternativeFormatting = true;
              showAvatars = true;
              showSelfTyping = true;
            };
          };
          unindent.enabled = true;
          viewJson.enabled = true;
          volumeManipulator.enabled = true;
          whosWatching.enabled = true;
        };
      };
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
      enable = config.guiApps;

      profiles = {
        default = {
          accountsOrder = [
            "Personal"
          ];
          isDefault = true;
        };
      };
    };

    tmux = {
      # enable = true;

      baseIndex = 1;
      clock24 = true;
      escapeTime = 0;
      keyMode = "vi";
      prefix = "C-a";
      terminal = "tmux-256color";

      plugins = with pkgs; [
        tmuxPlugins.resurrect
        tmuxPlugins.yank
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
          '';
        }
        {
          plugin = tmuxPlugins.tmux-sessionx;
          extraConfig = ''
            set -g @sessionx-bind o
          '';
        }
      ];

      extraConfig = ''
        set -g allow-passthrough on

        set-option -sa terminal-overrides ",xterm*:Tc"

        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -hc "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
      '';
    };

    zellij = {
      enable = lib.mkDefault (builtins.all (x: !x) [
        config.programs.kitty.enable
        config.programs.ghostty.enable
      ]);

      # TODO: revisit in 25.11, this shouldn't be required
      inherit
        (config.home.shell)
        enableBashIntegration
        enableFishIntegration
        enableZshIntegration
        ;

      settings = {
        copy_on_select = false;
        layout_dir = toString ./zellij-layouts;
        show_startup_tips = false;
        session_serialization = false; # TODO: change when they save properly
        support_kitty_keyboard_protocol = false; # HACK: remove this line when helix's version updates past 25.07.01
        # TODO: check on this in 25.11
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
          bind \cz 'fg 2>/dev/null; commandline -f repaint'
        ''
        + lib.optionalString (zellij.enable && zellij.enableFishIntegration) # fish
        
        ''
          eval (${lib.getExe zellij.package} setup --generate-completion fish | string collect)
        ''
        + lib.optionalString tmux.enable # fish
        
        ''
          if not set -q TMUX; and not set -q DISABLE_TMUX
            tmux attach -t shell >/dev/null 2>&1; or tmux new -s shell
          end
        '';

      shellAbbrs = {
        zbw = "zig build -Dno-bin --watch -fincremental --prominent-compile-errors";
      };
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
