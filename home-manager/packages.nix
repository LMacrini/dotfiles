{
  pkgs,
  lib,
  cfg,
  config,
  ...
}@params:
{
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

      "*.{nix,hs,json,jsonc,json5,yaml,yml,toml,gleam}" = {
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
    };

    file = {
      ".blerc" = {
        source = ./home/.blerc;
      };
    };

    packages =
      with pkgs;
      [
        unstable.flow-control
        (nixfmt-tree.override {
          nixfmtPackage = nixfmt-rfc-style;
        })
        nix-output-monitor
        rip2
        weechat
      ]
      ++ lib.optionals config.guiApps [
        bitwarden-desktop
        (discord.override {
          withOpenASAR = true;
          withEquicord = true;

          equicord =
            let
              shyTyping = builtins.fetchGit {
                url = "https://git.nin0.dev/Sqaaakoi-VencordUserPlugins/shyTyping";
                rev = "a6f6a21cf5a64792cb049067b6e3536636fcfa37";
              };
            in
            unstable.equicord.overrideAttrs {
              preBuild = ''
                mkdir ./src/userplugins
                cp -r ${shyTyping} ./src/userplugins
              '';
            };
        })
        keymapp
      ];
  };

  services = {
    mpd = {
      enable = true;
    };

    swayidle =
      let
        swaylock = lib.getExe config.programs.swaylock.package;
        brightnessctl = lib.getExe pkgs.brightnessctl;
      in
      {
        events = [
          {
            event = "before-sleep";
            command = "${swaylock} --fade-in 0";
          }
          {
            event = "lock";
            command = "${swaylock} --grace 10";
          }
        ];
        timeouts = [
          {
            timeout = 150;
            command = "${brightnessctl} -s set 10";
            resumeCommand = "${brightnessctl} -r";
          }
          {
            timeout = 300;
            command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
          }
          {
            timeout = 900;
            command = "${lib.getExe' pkgs.systemd "systemctl"} suspend";
          }
        ];
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

    librewolf = import ./librewolf.nix params;

    git = {
      enable = true;
      settings = {
        alias = {
          co = "checkout";
        };
        credential = {
          helper = "store";
        };
        user = {
          email = "seijamail@duck.com";
          name = "Seija";
        };
      };
    };

    helix = {
      enable = true;
      extraPackages = with pkgs; [
        marksman
        nixd
      ];

      defaultEditor = true;

      settings = {
        editor = {
          cursor-shape = {
            insert = "block";
            normal = "block";
            select = "underline";
          };

          line-number = "relative";
          mouse = false;
          rulers = [
            80
            100
          ];
          soft-wrap.enable = true;
          trim-trailing-whitespace = true;
        };

        keys =
          lib.recursiveUpdate
            {
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
            }
            (
              lib.optionalAttrs (config.programs.kitty.enable || config.programs.ghostty.enable) {
                normal = {
                  tab = "move_parent_node_end";
                  S-tab = "move_parent_node_start";
                };

                select = {
                  tab = "extend_parent_node_end";
                  S-tab = "extend_parent_node_start";
                };
              }
            );
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
      name = "java"
      formatter = { command = 'google-java-format', args = ["-"] }

      [[language]]
      name = "javascript"
      formatter = { command = 'prettier', args = ["--parser", "typescript"] }
      auto-format = true

      [[language]]
      name = "python"
      language-servers = ["basedpyright", "ty", "ruff", "jedi", "pylsp"]

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
          tug = [
            "bookmark"
            "move"
            "main"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
          tugb = [
            "bookmark"
            "move"
            "--to"
            "@-"
          ];
        };

        user = {
          email = "seijamail@duck.com";
          name = "Seija";
        };

        ui = {
          default-command = "log";
          diff-editor = ":builtin";
          paginate = "never";
        };
      };
    };

    kakoune = {
      colorSchemePackage = pkgs.kakounePlugins.kakoune-catppuccin;
      config = {
        colorScheme = "catppuccin_macchiato";
      };

      extraConfig =
        # kak
        "";

      plugins = with pkgs.kakounePlugins; [
        fzf-kak
        hop-kak
        zig-kak
      ];
    };

    kitty = {
      enable = lib.mkDefault config.guiApps;

      enableGitIntegration = true;
      font = {
        name = cfg.fonts.nerdfont.name;
        package = cfg.fonts.nerdfont.package;
      };

      keybindings = {
        "kitty_mod+enter" = "launch --cwd=current";

        "kitty_mod+t" = "new_tab";
        "kitty+shift+alt" = "set_tab_title";
      }
      // lib.optionalAttrs (config.programs.tmux.enable || config.programs.zellij.enable) {
        "kitty_mod+t" = "no_op";
        "kitty_mod+enter" = "no_op";
      };

      shellIntegration = {
        mode = "no-cursor";
      };

      settings = {
        allow_remote_control = true;

        confirm_os_window_close = 0;

        cursor_trail = 1;

        enable_audio_bell = false;

        # kitty_mod = "ctrl+alt";

        # shell = "zellij -l welcome";
      };
    };

    lsd = {
      enable = true;
    };

    nh = {
      enable = true;
      package = pkgs.nh;

      flake = "${config.home.homeDirectory}/dotfiles";
    };

    nix-your-shell = {
      enable = true;
    };

    rmpc = {
      enable = true;
    };

    rofi = {
      extraConfig = {
        display-drun = ":3 ";
        show-icons = true;
      };
      modes = [
        "drun"
        "window"
        "run"
        "ssh"
        "filebrowser"
        "calc"
      ];
      package = pkgs.rofi.override {
        plugins = with pkgs; [
          rofi-calc
        ];
      };
    };

    starship = {
      enable = true;
      settings = import ./starship.nix;
    };

    swaylock = {
      package = pkgs.swaylock-effects;
      settings = {
        clock = true;
        daemonize = true;
        effect-blur = "7x5";
        fade-in = 1;
        image = "${pkgs.my.imgs}/share/background.jpg";
        indicator = true;
        ring-color = lib.mkForce "717df1";
      };
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

    waybar.settings.mainBar = {
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "idle_inhibitor"
        "power-profiles-daemon"
        "custom/notification"
        "pulseaudio"
        "battery"
      ];

      "battery" = {
        format = " {icon} {capacity}% ";
        format-charging = " 󱐋{icon} {capacity}% ";
        format-icons = [
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
      };

      "clock" = {
        format = "{:%F %H:%M}";
        interval = 1;
        tooltip-format = "{:%a %b %d %H:%M:%S %Y}";
        timezone = cfg.time.timeZone;
      };

      "custom/notification" = {
        tooltip = false;
        format = " {icon} ";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>";
          none = "";
          dnd-notification = "<span foreground='red'><sup></sup></span>";
          dnd-none = "";
          inhibited-notification = "<span foreground='red'><sup></sup></span>";
          inhibited-none = "";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
          dnd-inhibited-none = "";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -d -sw";
        on-click-right = "swaync-client -t -sw";
        escape = true;
      };

      "idle_inhibitor" = {
        format = " {icon} ";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };

      "power-profiles-daemon" = {
        format = " {icon} ";
        tooltip-format = "Power profile: {profile}\nDriver: {driver}";
        tooltip = true;
        format-icons = {
          default = "";
          performance = "";
          balanced = "";
          power-saver = "";
        };
      };

      "pulseaudio" = {
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";

        format = " {icon} {volume}% ";
        format-icons = {
          default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
          default-muted = "󰖁";
          headphone = "󰋋";
          headphone-muted = "󰟎";
          headset = "󰋎";
          headset-muted = "󰋐";
          "alsa_output.usb-SteelSeries_Arctis_Nova_3-00.analog-stereo" = "󰋎";
          "alsa_output.usb-SteelSeries_Arctis_Nova_3-00.analog-stereo-muted" = "󰋐";
        };
      };

      "tray" = {
        show-passive-items = true;
        spacing = 10;
        reverse-direction = true;
        sort-by-app-id = true;
      };
    };

    yt-dlp = {
      enable = true;
      package = pkgs.unstable.yt-dlp;
    };

    zellij = {
      enable = lib.mkDefault (
        builtins.all (x: !x) [
          config.programs.kitty.enable
          config.programs.ghostty.enable
        ]
      );

      # TODO: this shouldn't be required
      inherit (config.home.shell)
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
        # TODO: check on this in 26.05
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

      interactiveShellInit =
        with config.programs; # fish

        ''
          set fish_greeting
          bind \cz 'fg 2>/dev/null; commandline -f repaint'
        ''
        +
          lib.optionalString (zellij.enable && zellij.enableFishIntegration) # fish

            ''
              eval (${lib.getExe zellij.package} setup --generate-completion fish | string collect)
            ''
        +
          lib.optionalString tmux.enable # fish

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
        ''
        +
          lib.optionalString (config.programs.starship.enableTransience)
            # nu
            ''
              $env.TRANSIENT_PROMPT_COMMAND = {starship module character | $"\n($in)"}
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

      initContent =
        let
          # NOTE: Common order values:
          # 500 (mkBefore): Early initialization (replaces initExtraFirst)
          #
          # 550: Before completion initialization (replaces initExtraBeforeCompInit)
          #
          # 1000 (default): General configuration (replaces initExtra)
          #
          # 1500 (mkAfter): Last to run configuration
          after =
            lib.mkOrder 1500
            <|
              # zsh
              ''
                autoload -Uz add-zle-hook-widget
                add-zle-hook-widget zle-line-finish transient-prompt
              ''
              +
                lib.optionalString (config.programs.starship.enableTransience)
                  # zsh
                  ''
                    transient-prompt () {
                      PROMPT=$(starship module character) zle .reset-prompt
                    }
                  '';
        in
        lib.mkMerge [
          after
        ];
    };

    home-manager.enable = true;
  };
}
