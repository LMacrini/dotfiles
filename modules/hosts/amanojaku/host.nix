{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.amanojaku = self.lib.nixosSystem {
    aspects = [
      "general"
      "mango"
    ];
    module = self.nixosModules.amanojaku;
  };

  flake.nixosModules.amanojaku = {pkgs, ...}: {
    imports = [
      inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
    ];

    preferences = {
      laptop.enable = true;
      monitors = {
        eDP-1 = {
          width = 2880;
          height = 1920;
          refreshRate = 120.0;
          scale = 2.0;
        };
      };
    };

    services.openssh.enable = true;

    programs = {
      steam.enable = true;
    };

    hjem.users.lioma.packages = with pkgs; [
      libreoffice
      prince.fluxer-bin
    ];

    networking.hostName = "amanojaku";
    system.stateVersion = "25.05";
  };
}
