{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    dev.editors.vscode.enable = lib.mkEnableOption "Enables vscode";
  };

  config = lib.mkIf config.dev.editors.vscode.enable {
    environment.systemPackages = with pkgs; [
      unstable.vscode
    ];
  };
}
