{pkgs, ...}:
pkgs.mkShell {
  name = "dotfiles";
  packages = [
    (pkgs.writeShellScriptBin "buildiso" (builtins.readFile ./buildiso.sh))
    (pkgs.writeShellScriptBin "fmt" ''
      #!/usr/bin/env bash
      nix fmt .
    '')
  ];
}
