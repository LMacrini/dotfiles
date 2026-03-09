{inputs, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: let
    catppuccin = inputs'.catppuccin.packages.rofi;
  in {
    packages.rofi =
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
