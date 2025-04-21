{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    neovim = {
      url = "github:lmacrini/nvf-config";
      # inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

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

    hm-module = with inputs.home-manager; {
      "x86_64-linux" = nixosModules.default;
      "aarch64-darwin" = darwinModules.default;
    };

    mkLinuxHost = path:
      nixpkgs.lib.nixosSystem
      {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${path}
          inputs.nix-flatpak.nixosModules.nix-flatpak
          # inputs.home-manager.nixosModules.default
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
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/${path}
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

      darwinConfigurations = mkHosts "aarch64-darwin" [
        "Lionels-MacBook-Air"
      ];
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      formatter = pkgs.alejandra;
    });
}
