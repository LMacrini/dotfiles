{inputs, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    packages.rofi = let
      catppuccin = inputs'.catppuccin.packages.rofi;
    in
      (inputs.wrappers.wrapperModules.rofi.apply {
        inherit pkgs;

        settings = {
          display-drun = ":3 ";
          show-icons = true;
        };

        theme = {
          "@theme" = "${catppuccin}/catppuccin-default.rasi";
          "@import" = "${catppuccin}/themes/catppuccin-macchiato.rasi";
        };
      }).wrapper;
  };
}
