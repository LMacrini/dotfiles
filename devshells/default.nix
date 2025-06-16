{pkgs, ...}:
pkgs.mkShell {
  name = "dotfiles";
  packages = [
    pkgs.my.buildiso
  ];
}
