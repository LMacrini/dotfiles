{
  pkgs,
  inputs,
  ...
}:
(inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    ./nvf-configuration.nix
  ];
}).neovim
