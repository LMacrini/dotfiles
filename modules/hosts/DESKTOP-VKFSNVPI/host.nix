{self, ...}: {
  flake.nixosConfigurations.DESKTOP-VKFSNVPI = self.lib.nixosSystem {
    aspects = [
      "general"
      "mango"
    ];
    module = self.nixosModules.DESKTOP-VKFSNVPI;
  };

  flake.nixosModules.DESKTOP-VKFSNVPI = {pkgs, ...}: {
    preferences = {
      monitors = {
        DP-1 = {
          x = 0;
          y = 0;
          width = 2560;
          height = 1440;
          scale = 1.0;
          refreshRate = 144.0;
        };

        HDMI-A-2 = {
          x = 2560;
          y = 180;
          width = 1920;
          height = 1080;
          scale = 1.0;
          refreshRate = 144.001;
        };
      };
    };

    boot.kernelPackages = pkgs.linuxPackages_zen;

    programs = {
      steam.enable = true;
    };

    environment.systemPackages = with pkgs; [
      noisetorch
    ];

    hardware = {
      amdgpu.opencl.enable = true;
    };

    networking.hostName = "DESKTOP-VKFSNVPI";
    system.stateVersion = "24.11";
  };
}
