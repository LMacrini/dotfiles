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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixcord.url = "github:kaylorben/nixcord";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    nix-darwin,
    ...
  } @ inputs: let
    eachSystem = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    overlay = eachSystem (system: _: _: {
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      quickshell = inputs.quickshell.packages.${system}.default.override {
        withQtSvg = true;
        withWayland = true;
        withPipewire = true;
        withPam = true;
        withHyprland = true;
      };
    });

    hm-module = with inputs.home-manager; {
      "x86_64-linux" = nixosModules.default;
      "aarch64-darwin" = darwinModules.default;
    };

    resources = ./resources;
    extraHome = path: if (nixpkgs.lib.pathIsRegularFile ./hosts/${path}/home.nix) then import ./hosts/${path}/home.nix else {};

    mkLinuxHost = path:
      nixpkgs.lib.nixosSystem
      {
        specialArgs = {
          inherit inputs resources;
          os = "linux";
          extraHome = extraHome path;
        };
        modules = [
          ./hosts/${path}
          ./modules/linux
          ./modules/universal
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.catppuccin.nixosModules.catppuccin
          hm-module.x86_64-linux
          {
            nixpkgs.overlays = [overlay.x86_64-linux];
          }
        ];
      };

    mkDarwinHost = path:
      nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs resources;
          os = "darwin";
          extraHome = extraHome path;
        };
        modules = [
          ./hosts/${path}
          ./modules/darwin
          ./modules/universal
          hm-module.aarch64-darwin
          {nixpkgs.overlays = [overlay.aarch64-darwin];}
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
          "live"
        ];

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
