{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.lionels-laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.lionels-laptop
    ];
  };

  flake.nixosModules.lionels-laptop = {
    imports = [
      self.nixosModules.mango
      self.nixosModules.discord
    ];

    preferences.monitors = {
      eDP-1 = {
        width = 1920;
        height = 1920;

        x = 0;
        y = 0;

        scale = 1.0;
        refreshRate = 144.0;
      };
    };

    networking.hostName = "lionels-laptop";

    system.stateVersion = "25.11";
  };
}
