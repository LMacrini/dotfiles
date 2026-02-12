{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.kitty =
      (inputs.wrappers.wrapperModules.kitty.apply {
        inherit pkgs;
        settings = {
          include = "${pkgs.kitty-themes}/share/kitty-themes/themes/Catppuccin-Macchiato.conf";
          shell_integration = "no-rc no-cursor";
          allow_remote_control = "yes";
          confirm_os_window_close = 0;
          cursor_trail = 1;
          enable_audio_bell = "no";

          map = [
            "kitty_mod+enter launch --cwd=current"
            "kitty_mod+t new_tab"
          ];
        };
      }).wrapper;
  };
}
