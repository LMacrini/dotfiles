{
  lib,
  self,
  ...
}: {
  flake.aspects.wallpaper.module = let
    mod = {
      options = with lib; {
        wallpaper.image = mkOption {
          type = types.path;
          default = "${self.images}/background.jpg";
        };
      };
    };
  in {
    hjem.extraModules = [mod];
  };
}
