{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    neovim = {
      url = "github:lmacrini/nvf-config";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";

    # nixcord.url = "github:kaylorben/nixcord";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    nix-darwin,
    ...
  } @ inputs: let
    eachSystem = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    overlay-unstable = eachSystem (system: _: _: {
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    });

    hm-module = with inputs.home-manager; {
      "x86_64-linux" = nixosModules.default;
      "aarch64-darwin" = darwinModules.default;
    };

    mkLinuxHost = path:
      nixpkgs.lib.nixosSystem
      {
        specialArgs = {
          inherit inputs;
          os = "linux";
        };
        modules = [
          ./hosts/${path}
          ./modules/linux
          ./modules/universal
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.catppuccin.nixosModules.catppuccin
          hm-module.x86_64-linux
          (
            _: {
              nixpkgs.overlays = [overlay-unstable.x86_64-linux];
            }
          )
        ];
      };

    mkDarwinHost = path:
      nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          os = "darwin";
        };
        modules = [
          ./hosts/${path}
          ./modules/darwin
          ./modules/universal
          hm-module.aarch64-darwin
          (_: {nixpkgs.overlays = [overlay-unstable.aarch64-darwin];})
        ];
      };

    mkHost = system:
      if system == "x86_64-linux"
      then mkLinuxHost
      else if system == "aarch64-darwin"
      then mkDarwinHost
      else abort "unsupported system";

    mkHosts = system: hosts:
      builtins.listToAttrs (map (host: {
          name = host;
          value = mkHost system host;
        })
        hosts);
  in
    {
      nixosConfigurations =
        mkHosts "x86_64-linux" [
          "DESKTOP-VKFSNVPI"
          "lionels-laptop"
          "vm"
        ]
        // {
          live = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              os = "linux";
            };
            modules = [
              ./hosts/liveiso
              ./modules/linux
              ./modules/universal
              inputs.nix-flatpak.nixosModules.nix-flatpak
              inputs.home-manager.nixosModules.default
              inputs.catppuccin.nixosModules.catppuccin
              (
                _: {
                  nixpkgs.overlays = [overlay-unstable.x86_64-linux];
                }
              )
            ];
          };
        };

      darwinConfigurations = mkHosts "aarch64-darwin" [
        "Lionels-MacBook-Air"
      ];
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;

      devShells = {
        default = import ./shell.nix {
          inherit pkgs;
        };
      };
    });
}
