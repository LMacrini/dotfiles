{
  lib,
  config,
  ...
}: {
  imports = [
    ./vscode.nix
    ./neovim.nix
  ];

  options = {
    dev.editors.enable = lib.mkEnableOption "Enables code editors";
  };

  config = {
    dev.editors.vscode.enable = lib.mkDefault false;
    dev.editors.neovim.enable = lib.mkDefault config.dev.editors.enable;
  };
}
