{
  pkgs,
  lib,
  config,
  cfg,
  ...
}: {
  programs.emacs = {
    package =
      if config.guiApps
      then pkgs.emacs-unstable-pgtk
      else pkgs.emacs-unstable-nox;

    extraPackages = epkgs:
      with epkgs; [
        avy
        catppuccin-theme
        consult
        dashboard
        direnv
        ivy
        lsp-mode
        meow
        nerd-icons
        nix-mode
        page-break-lines
        projectile
      ];
  };

  # xdg.configFile.emacs = lib.mkIf config.programs.emacs.enable {
  #   recursive = true;
  #   source = ./config;
  # };
  xdg.configFile = lib.mkIf config.programs.emacs.enable {
    "emacs/init.el".source = pkgs.replaceVars ./config/init.el {
      nerdfont = cfg.fonts.nerdFont.name;
    };
    "emacs/icon.png".source = ./config/icon.png;
  };
}
