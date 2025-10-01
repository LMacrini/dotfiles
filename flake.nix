{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    zig = {
      url = "github:silversquirl/zig-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix/release-25.05";

    moonlight = {
      url = "github:moonlight-mod/moonlight/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

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

    wayland-pipewire-idle-inhibit = {
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixcord.url = "github:kaylorben/nixcord";
  };

  outputs = {
    nixpkgs,
    nix-darwin,
    determinate,
    ...
  } @ inputs: let
    defaultSystems = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forAllSystems = f: builtins.mapAttrs f nixpkgs.legacyPackages;

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
                else defaultSystems;
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
                  config.allowUnfree = true;
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

    eachSystem = nixpkgs.lib.genAttrs defaultSystems;
    overlay = eachSystem (system: next: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = prev.config.allowUnfree;
      };

      quickshell = inputs.quickshell.packages.${system}.default.override {
        withQtSvg = true;
        withWayland = true;
        withPipewire = true;
        withPam = true;
        withHyprland = true;
      };

      gaming = inputs.nix-gaming.packages.${system};

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
          determinate.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.catppuccin.nixosModules.catppuccin
          inputs.niri.nixosModules.niri
          inputs.nix-gaming.nixosModules.pipewireLowLatency
          inputs.nix-gaming.nixosModules.platformOptimizations
          inputs.nix-gaming.nixosModules.wine
          hm-module.x86_64-linux
          {
            nixpkgs.overlays = [
              (import inputs.emacs-overlay)
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
  in {
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

    formatter = forAllSystems (system: pkgs: pkgs.alejandra);

    devShells = forAllSystems (system: pkgs: {
      default = import ./devshells {
        pkgs = pkgs.extend overlay.${system};
      };
    });
  };
}
