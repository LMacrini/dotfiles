{ lib, ... }:
{
  imports = [
    ./tlp.nix
  ];

  options = {
    laptop.enable = lib.mkEnableOption "Enable laptop options";
  };
}
