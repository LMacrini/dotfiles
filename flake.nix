{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.5.0";
  };

  outputs = { self, nixpkgs, ... }@inputs: 
  let
    system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
  in {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/home
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.home-manager.nixosModules.default
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/laptop
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.home-manager.nixosModules.default
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
      ];
    };

    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/vm
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.home-manager.nixosModules.default
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
      ];
    };
  };
}
