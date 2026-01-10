{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  gpu.amd.enable = true;

  networking.hostName = "amanojaku";

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.lioma.extraGroups = [
    "docker"
    "libvirtd"
  ];

  games.light.enable = true;
  games.launchers.enable = true;

  laptop.enable = true;

  libreoffice.enable = true;

  services.fwupd.enable = true;

  ssh.enable = true;

  specialisation = {
    Work = lib.mkIf false {
      configuration = {
        environment.etc.specialisation.text = "Work";
        system.nixos.tags = [ "Work" ];

        sudoInsults.enable = false;

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
  };

  stateVersion = "25.05";
}
