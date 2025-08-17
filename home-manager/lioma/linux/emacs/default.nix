{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.emacs = {
    enable = lib.mkDefault true;
    package = pkgs.emacs-unstable-pgtk;
    extraPackages = epkgs: [
      epkgs.catppuccin-theme
      epkgs.dashboard
      epkgs.meow
      epkgs.nerd-icons
      epkgs.page-break-lines
      epkgs.projectile
    ];
  };

  xdg.configFile.emacs = lib.mkIf config.programs.emacs.enable {
    recursive = true;
    source = ./config;
  };
}
