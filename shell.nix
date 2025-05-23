{pkgs, ...}: 
pkgs.mkShell {
  name = "dotfiles";
  packages = [
    (pkgs.writeShellScriptBin "buildiso" (builtins.readFile ./buildiso.sh))
  ];
}
