{pkgs, ...}:
pkgs.mkShellNoCC {
  name = "dotfiles";
  packages = with pkgs; [
    my.buildiso
    zig.nightly
  ];
}
