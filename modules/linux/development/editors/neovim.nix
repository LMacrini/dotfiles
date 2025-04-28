{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: {
  options = {
    dev.editors.neovim.enable = lib.mkEnableOption "Enables neovim";
  };

  config = lib.mkIf config.dev.editors.neovim.enable {
    programs.nano.enable = false;

    environment.sessionVariables = {
      EDITOR = "nvim";
    };

    environment.systemPackages = [
      inputs.neovim.packages.${pkgs.stdenv.system}.default
    ];
  };
}
