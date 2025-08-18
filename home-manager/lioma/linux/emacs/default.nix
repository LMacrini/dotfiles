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
        meow
        nerd-icons
        page-break-lines
        projectile
      ];
  };

  xdg.configFile.emacs = lib.mkIf config.programs.emacs.enable {
    recursive = true;
    source = ./config;
  };
}
