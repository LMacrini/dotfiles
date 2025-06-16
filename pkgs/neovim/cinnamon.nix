{lib, config, ...}: {
  options = {
    cinnamon.enable = lib.mkEnableOption "Enable cinnamon";
  };

  config = lib.mkIf config.cinnamon.enable {
    vim = {
      visuals.cinnamon-nvim = {
        enable = true;
        setupOpts = {
          keymaps = {
            basic = true;
            extra = true;
          };

          options = {
            mode = "cursor";
            count_only = false;
            delay = 5;

            max_delta = {
              line = false;
              column = false;
              time = 500;
            };

            step_size = {
              vertical = 1;
              horizontal = 2;
            };
          };
        };
      };

      luaConfigRC.cinnamon-nvim = ''
        local cinnamon = require("cinnamon")

        vim.keymap.set("n", "<S-Down>", function()
          cinnamon.scroll("<S-Down>")
        end)

        vim.keymap.set("n", "<S-Up>", function()
          cinnamon.scroll("<S-Up>")
        end)
      '';
    };
  };
}
