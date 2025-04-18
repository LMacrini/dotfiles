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

    neovim = {
      url = "github:lmacrini/nvf-config";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # nixcord.url = "github:kaylorben/nixcord";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    overlay-unstable = _: _: {
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    };

    utils = {
      # mkUser = args: let
      #   user =
      #     if builtins.typeOf args == "string" then { name = args; follows = args; }
      #     else if builtins.typeOf args == "set" then with args; {
      #       name = if builtins.typeOf name == "string" then name else abort "name must be a string";
      #       follows =
      #         if (builtins.tryEval follows).success then
      #           if builtins.typeOf follows == "string" then follows
      #           else abort "follows must be a string"
      #         else name;
      #     }
      #     else abort "invalid argument for mkUser";
      #   in import ./home-manager/${user.follows};
      mkUser = name: import ./home-manager/${name};
    };

    mkHost = path:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${path}
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.home-manager.nixosModules.default
          (
            _: {
              nixpkgs.overlays = [overlay-unstable];
            }
          )
        ];
      };

    mkHosts = hosts:
      builtins.listToAttrs (map (host: {
          name = host;
          value = mkHost host;
        })
        hosts);
  in {
    nixosConfigurations =
      mkHosts [
        "DESKTOP-VKFSNVPI"
        "lionels-laptop"
        "vm"
      ]
      // {
        live = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
            ./hosts/liveiso
            ./modules
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.home-manager.nixosModules.default
            (
              _: {
                nixpkgs.overlays = [overlay-unstable];
              }
            )
          ];
        };
      };
  };
}
