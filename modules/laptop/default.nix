{lib, config, ...}: {
  imports = [
    ./tlp.nix
  ];

  options = {
    laptop.enable = lib.mkEnableOption "Enable laptop options";
  };

  config = {
    laptop.tlp.enable = lib.mkDefault config.laptop.enable;
  };
}
