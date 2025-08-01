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

    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fjordlauncher = {
      url = "github:unmojang/fjordlauncher";
    };

    zig-overlay = {
      url = "github:bandithedoge/zig-overlay";
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
    myPkgs = let
      pkgsDir = ./pkgs;
      rawPkgs = builtins.readDir pkgsDir;
      pkgsList = nixpkgs.lib.attrsToList rawPkgs;

      parsedPkgs =
        map (
          {
            name,
            value,
          }:
            if value == "directory"
            then {
              inherit name;
              package = pkgsDir + "/${name}";
              systems =
                if builtins.pathExists (pkgsDir + "/${name}/systems.nix")
                then import (pkgsDir + "/${name}/systems.nix")
                else flake-utils.lib.defaultSystems;
            }
            else builtins.abort "non directory found"
        )
        pkgsList;

      systemPkgsList =
        map (
          {
            name,
            package,
            systems,
          }: let
            systemPackages =
              map (system: let
                pkgs = import nixpkgs {
                  inherit system;
                  overlays = [overlay.${system}];
                };
              in {
                name = system;
                value = {
                  ${name} = pkgs.callPackage package {inherit inputs;};
                };
              })
              systems;
          in
            builtins.listToAttrs systemPackages
        )
        parsedPkgs;
    in
      builtins.foldl' nixpkgs.lib.recursiveUpdate {} systemPkgsList;

    eachSystem = nixpkgs.lib.genAttrs flake-utils.lib.defaultSystems;
    overlay = eachSystem (system: next: prev: {
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

      my = myPkgs.${system};

      fjordlauncher = inputs.fjordlauncher.packages.${system}.default;
    });

    hm-module = with inputs.home-manager; {
      "x86_64-linux" = nixosModules.default;
      "aarch64-darwin" = darwinModules.default;
    };

    extraHome = path:
      if (builtins.pathExists ./hosts/${path}/home.nix)
      then import ./hosts/${path}/home.nix
      else {};

    mkLinuxHost = path:
      nixpkgs.lib.nixosSystem
      {
        specialArgs = {
          inherit inputs;
          os = "linux";
          extraHome = extraHome path;
        };
        modules = [
          ./hosts/${path}
          ./modules/linux
          ./modules/universal
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.catppuccin.nixosModules.catppuccin
          inputs.niri.nixosModules.niri
          hm-module.x86_64-linux
          {
            nixpkgs.overlays = [
              overlay.x86_64-linux
              (_: prev: {
                gdm = prev.my.gdm-wam;
              })
            ];
          }
        ];
      };

    mkDarwinHost = path:
      nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
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
      nixosConfigurations = mkHosts "x86_64-linux" [
        "DESKTOP-VKFSNVPI"
        "amanojaku"
        "lionels-laptop"
        "vm"
        "live"
      ];

      darwinConfigurations = mkHosts "aarch64-darwin" [
        "Lionels-MacBook-Air"
      ];

      packages = myPkgs;
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlay.${system}];
      };
    in {
      formatter = pkgs.alejandra;

      devShells = {
        default = import ./devshells {
          inherit pkgs;
        };
      };
    });
}
