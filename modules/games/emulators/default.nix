{
  lib,
  config,
  ...
}: {
  imports = [
    ./ryujinx.nix
    ./torzu.nix
    ./dolphin.nix
  ];

  options = {
    games.emulators.enable = lib.mkEnableOption "Enable all emulators";
  };

  config = {
    games.emulators = let
      default = config.games.emulators.enable;
    in {
      dolphin.enable = lib.mkDefault default;
      torzu.enable = lib.mkDefault default;
      ryujinx.enable = lib.mkDefault false;
    };
  };
}
