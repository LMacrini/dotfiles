{
  lib,
  self,
  ...
}: {
  flake.nixosModules.wallpaper = {
    options = with lib; {
      wallpaper.image = mkOption {
        type = types.path;
        default = "${self.images}/background.jpg";
      };
    };
  };
}
