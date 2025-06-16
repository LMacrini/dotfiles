{
  pkgs,
  lib,
  ...
}: let
  mac = pkgs.stdenv.isDarwin;
  open =
    if mac
    then "open"
    else "xdg-open";
in {
  imports = [
    ./cinnamon.nix
  ];

  cinnamon.enable = false;

  vim = {
    options = {
      shiftwidth = 2;
      tabstop = 4;
      tm = 1000;
      ignorecase = true;
      smartcase = true;
      scrolloff = 3;
    };

    theme = {
      enable = true;
      name = "catppuccin";
      style = "macchiato";
    };

    extraPlugins = with pkgs.vimPlugins; {
      vim-suda = {
        package = vim-suda;
        setup = ''
          vim.api.nvim_create_user_command("W", function(opts)
            vim.cmd("SudaWrite " .. opts.args)
          end, { nargs = "?" })
        '';
      };

      tabby-nvim = {
        package = tabby-nvim;
        setup = ''
          local theme = {
            fill = 'TabLineFill',
            -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
            head = 'TabLine',
            current_tab = 'TabLineSel',
            tab = 'TabLine',
            win = 'TabLine',
            tail = 'TabLine',
          }

          require('tabby').setup({
            line = function(line)
              return {
                {
                  { ' 󱣳 ', hl = theme.head },
                  line.sep('', theme.head, theme.fill),
                },
                line.tabs().foreach(function(tab)
                  local hl = tab.is_current() and theme.current_tab or theme.tab
                  return {
                    line.sep('', hl, theme.fill),
                    -- tab.is_current() and '' or '󰆣',
                    -- tab.is_current() and '' or tab.current_win().file_icon(),
                    tab.current_win().file_icon(),
                    tab.number(),
                    tab.name(),
                    tab.close_btn(''),
                    line.sep('', hl, theme.fill),
                    hl = hl,
                    margin = ' ',
                  }
                end),
                line.spacer(),
                line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                  return {
                    line.sep('', theme.win, theme.fill),
                    -- win.is_current() and '' or '',
                    win.is_current() and '' or win.file_icon(),
                    win.buf_name(),
                    line.sep('', theme.win, theme.fill),
                    hl = theme.win,
                    margin = ' ',
                  }
                end),
                {
                  line.sep('', theme.tail, theme.fill),
                  { '  ', hl = theme.tail },
                },
                hl = theme.fill,
              }
            end,
          })
        '';
      };
    };

    lazy.plugins = with pkgs.vimPlugins; {
      "vim-matchup" = {
        package = vim-matchup;
        setupModule = "match-up";
        after = ''
          vim.g.matchup_matchparen_offscreen = { method = "popup" }
        '';

        event = ["BufEnter"];
      };

      "mini.indentscope" = {
        package = mini-indentscope;
        setupModule = "mini.indentscope";
        setupOpts = {
          symbol = "▏";
        };
        after = ''
          vim.api.nvim_create_autocmd({ "FileType" }, {
            desc = "Disable indentscope for certain filetypes",
            callback = function()
              local ignored_filetypes = {
                "aerial",
                "dashboard",
                "help",
                "notify",
                "toggleterm",
                "Trouble"
              }
              if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
                vim.b.miniindentscope_disable = true
              end
            end,
          })
        '';

        event = ["BufEnter"];
      };

      "smart-splits.nvim" = {
        package = smart-splits-nvim;
        setupModule = "smart-splits";
        after = ''
          main = "ibl"
          vim.keymap.set(
            "n",
            "<leader>r",
            function()
              if not vim.g.smart_resize_mode then
                vim.cmd("SmartResizeMode")
              else
                print("Smart Resize Mode is already enabled!")
              end
            end,
            { noremap = true, silent = true, desc = "Enable Resizing", }
          )
        '';
        event = ["BufEnter"];

        setupOpts = {
          resize_mode = {
            silent = true;
            resize_keys = [
              "<Left>"
              "<Down>"
              "<Up>"
              "<Right>"
            ];
          };
        };

        keys = let
          osbind = key:
            if mac
            then "<C-S-" + key + ">"
            else "<C-" + key + ">";
        in [
          {
            action = ":SmartCursorMoveLeft<CR>";
            key = osbind "Left";
            mode = "n";
          }
          {
            action = ":SmartCursorMoveRight<CR>";
            key = osbind "Right";
            mode = "n";
          }
          {
            action = ":SmartCursorMoveUp<CR>";
            key = osbind "Up";
            mode = "n";
          }
          {
            action = ":SmartCursorMoveDown<CR>";
            key = osbind "Down";
            mode = "n";
          }

          {
            action = ":SmartSwapLeft<CR>";
            key = "<leader>m<Left>";
            mode = "n";
          }
          {
            action = ":SmartSwapRight<CR>";
            key = "<leader>m<Right>";
            mode = "n";
          }
          {
            action = ":SmartSwapUp<CR>";
            key = "<leader>m<Ups.";
            mode = "n";
          }
          {
            action = ":SmartSwapUp<CR>";
            key = "<leader>m<Down>";
            mode = "n";
          }
        ];
      };
    };

    preventJunkFiles = true;
    clipboard = {
      enable = true;
      registers = "unnamedplus";
    };

    utility = {
      motion.hop.enable = true;
      outline.aerial-nvim.enable = true;
      preview.markdownPreview.enable = true;
      surround = {
        enable = true;
        useVendoredKeybindings = false;
      };
    };

    autopairs.nvim-autopairs.enable = true;
    statusline.lualine = {
      enable = true;
      extraActiveSection = {
        c = [
          ''
            function()
              return vim.g.smart_resize_mode and "RESIZING SPLITS" or ""
            end
          ''
        ];
      };
    };
    telescope = {
      enable = true;
      mappings = {
        findFiles = null;
      };
    };
    autocomplete.blink-cmp = {
      enable = true;
      setupOpts = {
        signature.enabled = true;
        snippets.expand = lib.generators.mkLuaInline ''
          function(snippet) 
            local text = snippet
            local before_paren = snippet:match("^(.-)%(")
            if not snippet:match("%(%s*%)$") and before_paren then
              text = before_paren .. "(''${1:})"
            end
            vim.snippet.expand(text)
          end
        '';

        completion.list.selection = {
          auto_insert = false;
        };
      };
    };
    notes.todo-comments.enable = true;
    notify.nvim-notify = {
      enable = true;
      setupOpts = {
        render = "default";
      };
    };
    terminal.toggleterm = {
      enable = true;
      setupOpts = {
        direction = "float";
      };
    };
    visuals = {
      highlight-undo = {
        enable = true;
        setupOpts = {
          ignored_filetypes = [
            "dashboard"
          ];
        };
      };
      nvim-scrollbar = {
        enable = true;
        setupOpts.excluded_filetypes = [
          "dashboard"
          "notify"
        ];
      };
      nvim-web-devicons.enable = true;
    };

    mini = {
      ai.enable = true;
    };

    dashboard.dashboard-nvim = {
      enable = true;
      setupOpts = {
        config = {
          header = import ./dashboardheader.nix "seija";

          packages.enable = false;

          project.action = lib.generators.mkLuaInline ''
            function(path)
              vim.cmd("Telescope find_files cwd=" .. string.gsub(path, " ", "\\ "))
            end
          '';

          shortcut = [
            {
              icon = " ";
              desc = "New file";
              action = "enew";
              key = "n";
            }
            {
              icon = " ";
              desc = "Github Profile";
              action = "silent exec '!${open} https://github.com/lmacrini'";
              key = "g";
            }
            {
              icon = "󰈆 ";
              desc = "Quit";
              action = "q";
              key = "q";
            }
          ];

          footer = [
            ""
            "󱣳 The 25th Wam"
          ];
        };
      };
    };

    git.enable = true;

    lsp = {
      enable = true;
      trouble.enable = true;
      lspkind = {
        enable = true;
        setupOpts.mode = "symbol";
      };
    };

    languages = {
      enableTreesitter = true;

      nix = {
        enable = true;

        extraDiagnostics.enable = true;
      };

      zig = {
        enable = true;
      };

      nu = {
        enable = true;
      };

      python.enable = true;

      html = {
        enable = true;
      };
      ts = {
        enable = true;
      };

      markdown = {
        enable = true;
        extensions = {
          render-markdown-nvim.enable = true;
        };
      };
      typst = {
        enable = true;
        extensions.typst-preview-nvim.enable = true;
      };
    };

    treesitter = {
      autotagHtml = true;
      grammars = with pkgs.vimPlugins; with nvim-treesitter.builtGrammars; [
        nvim-treesitter-parsers.qmljs
        nvim-treesitter-parsers.qmldir
      ];
    };

    keymaps = [
      {
        key = "<Esc>";
        mode = "t";
        action = "<C-\\><C-N>";
      }
    ];

    maps.normal = {
      "<Esc>" = {
        action = ":noh<CR>";
      };

      "<leader>e" = {
        action = ":Telescope fd<CR>";
        desc = "Find Files";
      };

      "<leader>E" = {
        action = ":Telescope fd hidden=true<CR>";
        desc = "Find Files (hidden)";
      };

      "<Enter>" = {
        action = ":HopWord<CR>";
      };

      "<leader>F" = {
        action = ":AerialToggle!<CR>";
        desc = "Toggle Aerial";
      };

      "<leader>md" = {
        action = ":MarkdownPreviewToggle<CR>";
      };

      "<leader>nt" = {
        action = ":tabnew<CR>:Telescope fd<CR>";
      };

      "<leader>nh" = {
        action = ":sp<CR>";
      };

      "<leader>nv" = {
        action = ":vsp<CR>";
      };
    };

    extraLuaFiles = [
      ./qmlls.lua
    ];

    extraPackages = with pkgs; [
      kdePackages.qtdeclarative
    ];
  };
}
