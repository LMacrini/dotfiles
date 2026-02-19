{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.helix =
      (inputs.wrappers.wrapperModules.helix.apply {
        inherit pkgs;
        settings = {
          theme = "catppuccin_macchiato";

          editor = {
            color-modes = true;
            line-number = "relative";
            mouse = false;
            trim-trailing-whitespace = true;

            cursor-shape = {
              insert = "block";
              normal = "block";
              select = "underline";
            };

            soft-wrap.enable = true;
          };

          keys = {
            insert =
              builtins.listToAttrs
              <| builtins.map (key: {
                name = key;
                value = "no_op";
              })
              <| [
                "left"
                "down"
                "up"
                "right"

                "end"
                "home"
                "pagedown"
                "pageup"
              ];

            normal = {
              S-tab = "move_parent_node_start";
              tab = "move_parent_node_end";
            };

            select = {
              S-tab = "extend_parent_node_start";
              tab = "extend_parent_node_end";
            };
          };
        };

        languages = {
          language = [
            {
              name = "nix";
              auto-format = true;
              formatter = {
                command = "nix";
                args = ["fmt"];
              };
            }
          ];

          language-server = {
            zls.config.enable_snippets = false;
          };
        };
      }).wrapper;
  };
}
