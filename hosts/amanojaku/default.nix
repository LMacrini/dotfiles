{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  gpu.amd.enable = true;

  networking.hostName = "amanojaku";

  games.light.enable = true;

  laptop.enable = true;

  libreoffice.enable = true;

  specialisation = {
    work.configuration = {
      system.nixos.tags = ["work"];

      home-manager.users.lioma = _: {
        programs.kitty.settings = {
          cursor_trail = lib.mkForce 0;
        };

        programs.niri.settings = {
          animations.enable = false;

          outputs.DP-3 = {
            enable = true;
            focus-at-startup = false;
            position = {
              x = -240;
              y = -1200;
            };
          };
        };
      };
    };
  };

  stateVersion = "25.05";
}
