{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs = {
        nixpkgs-stable.follows = "nixpkgs";
        nixpkgs-unstable.follows = "nixpkgs-unstable";
      };
    };

    neovim = {
      url = "github:lmacrini/nvf-config";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    overlay-unstable = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    mkHost = path:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${path}
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.home-manager.nixosModules.default
          (
            {
              config,
              pkgs,
              ...
            }: {
              nixpkgs.overlays = [overlay-unstable];
            }
          )
        ];
      };
  in {
    nixosConfigurations = {
      DESKTOP-VKFSNVPI = mkHost "DESKTOP-VKFSNVPI";
      lionels-laptop = mkHost "lionels-laptop";
      vm = mkHost "vm";
      live = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/liveiso
        ];
      };
    };
  };
}
