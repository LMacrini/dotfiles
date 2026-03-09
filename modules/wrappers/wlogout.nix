{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    catppuccin = inputs'.catppuccin.packages.wlogout;
    style = pkgs.writeText "style.css" ''
      @import url("${catppuccin}/themes/macchiato/pink.css");

      ${lib.concatMapStrings (icon:
          # css
          ''
            #${icon} {
              background-image: url("${catppuccin}/icons/wlogout/macchiato/pink/${icon}.svg");
            }
          '')
        [
          "hibernate"
          "lock"
          "logout"
          "reboot"
          "shutdown"
          "suspend"
        ]}
    '';
  in {
    packages.wlogout = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.wlogout;

      runtimeInputs = [
        pkgs.systemd
      ];

      flags = {
        "--css" = "${style}";
      };
    };
  };
}
