{lib, config, ...}: {
  imports = [
    ./ryujinx.nix
    ./dolphin.nix
  ];

  options = {
    games.emulators.enable = lib.mkEnableOption "Enable all emulators";
  };

  config = {
    games.emulators = let
        default = config.games.emulators.enable;
      in {
      ryujinx.enable = lib.mkDefault default;
      dolphin.enable = lib.mkDefault default;
    };
  };
}
