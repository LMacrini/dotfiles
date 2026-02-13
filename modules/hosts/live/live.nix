{
  inputs,
  self,
  lib,
  ...
}: {
  flake.packages."x86_64-linux".iso =
    (inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.iso
      ];
    }).config.system.build.isoImage;

  flake.nixosModules.iso = {
    modulesPath,
    pkgs,
    ...
  }: {
    imports = with self.nixosModules; [
      base
      "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ];

    services.getty = {
      autologinUser = lib.mkForce "lioma";
    };

    security.sudo.wheelNeedsPassword = false;

    users = {
      mutableUsers = lib.mkForce true;
      users = {
        lioma.hashedPassword = lib.mkForce null;
        nixos.enable = lib.mkForce false;
      };
    };

    networking.wireless.enable = false;

    kanata.enable = false;
    environment.systemPackages = [
      pkgs.self.installVm
      pkgs.self.kanata
    ];
  };
}
