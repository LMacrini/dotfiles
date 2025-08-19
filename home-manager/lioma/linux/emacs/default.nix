{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.emacs = {
    enable = lib.mkDefault true;
    package = pkgs.emacs-unstable-pgtk;
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

  xdg.configFile.emacs = lib.mkIf config.programs.emacs.enable {
    recursive = true;
    source = ./config;
  };
}
