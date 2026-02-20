{
  lib,
  self,
  ...
}: {
  flake.aspects.wallpaper.module = {
    options = with lib; {
      wallpaper.image = mkOption {
        type = types.path;
        default = "${self.images}/background.jpg";
      };
    };
  };
}
