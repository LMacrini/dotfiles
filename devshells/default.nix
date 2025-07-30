{pkgs, ...}:
pkgs.mkShell {
  name = "dotfiles";
  packages = with pkgs; [
    my.buildiso
    zig
    zls
  ];
}
