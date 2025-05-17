{
  lib,
  config,
  ...
}: {
  imports = [
    ./ryubing.nix
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
      ryubing.enable = lib.mkDefault default;
    };
  };
}
