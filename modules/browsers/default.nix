{ lib, ... }:
{
  imports = [
    ./floorp.nix
  ];

  options = {
    browsers.all.enable = lib.mkEnableOption "Enables all browsers unless explicitly changed";
  };

  config = {
    browsers.floorp.enable = lib.mkDefault true;
  };
}
