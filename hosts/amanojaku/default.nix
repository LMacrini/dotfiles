{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  gpu.amd.enable = true;

  networking.hostName = "amanojaku";

  games.light.enable = true;

  laptop.enable = true;

  libreoffice.enable = true;

  services.fwupd.enable = true;

  specialisation = {
    Work.configuration = {
      environment.etc.specialisation.text = "Work";
      system.nixos.tags = ["Work"];

      home-manager.users.lioma = _: {
        home.packages = with pkgs; [
          ungoogled-chromium
        ];

        programs.kitty.settings = {
          cursor_trail = lib.mkForce 0;
        };

        programs.niri.settings = {
          animations.enable = false;

          outputs.DP-4 = {
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
