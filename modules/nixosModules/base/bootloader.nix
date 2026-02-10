{self, ...}: {
  flake.nixosModules.base = {config, ...}: {
    boot.loader = {
      efi.canTouchEfiVariables = true;

      limine = {
        enable = true;

        style = {
          wallpapers = [
            "${self.images}/background.jpg"
          ];
          wallpaperStyle = "stretched";

          interface = {
            branding = "${config.system.nixos.distroName} ${config.system.nixos.release}";
            brandingColor = 6; # number from 0-7 that corresponds to:
            # 0: black, 1: red, 2: green, 3: brown, 4: blue, 5: magenta, 6: cyan, 7: gray
          };
        };

        extraConfig = ''
          quiet: yes
        '';
      };
    };
  };
}
