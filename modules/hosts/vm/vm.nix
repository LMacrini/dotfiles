{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.vmHost
    ];
  };

  flake.nixosModules.vmHost = {
    pkgs,
    config,
    ...
  }: {
    imports = with self.nixosModules; [
      base
    ];

    environment.systemPackages = with self.packages.${pkgs.stdenv.system}; [
      helix
    ];

    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    networking.hostName = "vm";

    system.stateVersion = config.system.nixos.release;
  };
}
