{
  self,
  lib,
  ...
}: {
  flake.packages."x86_64-linux".iso =
    (self.lib.nixosSystem {
      aspects = ["hjem"];
      module = self.nixosModules.iso;
    }).config.system.build.isoImage;

  flake.nixosModules.iso = {
    modulesPath,
    self',
    ...
  }: {
    imports = [
      "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ];

    services = {
      getty = {
        autologinUser = lib.mkForce "lioma";
      };
      kanata.enable = false;
    };

    security.sudo.wheelNeedsPassword = false;

    boot.loader.limine.enable = lib.mkForce false;

    users = {
      mutableUsers = lib.mkForce true;
      users = {
        lioma.hashedPassword = lib.mkForce null;
        nixos.enable = lib.mkForce false;
      };
    };

    networking.wireless.enable = false;

    environment.systemPackages = [
      self'.packages.installVm
    ];
  };
}
