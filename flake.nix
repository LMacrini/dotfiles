{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix/release-25.11";

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

    nixos-hardware.url = "github:nixos/nixos-hardware";

    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    mango = {
      url = "github:dreammaomao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fjordlauncher = {
      url = "github:unmojang/fjordlauncher";
    };

    wayland-pipewire-idle-inhibit = {
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      defaultSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      forAllSystems = f: builtins.mapAttrs f nixpkgs.legacyPackages;

      myPkgs =
        let
          pkgsDir = ./pkgs;
          rawPkgs = builtins.readDir pkgsDir;
          pkgsList = nixpkgs.lib.attrsToList rawPkgs;

          parsedPkgs = map (
            {
              name,
              value,
            }:
            if value == "directory" then
              {
                inherit name;
                package = pkgsDir + "/${name}";
                systems =
                  if builtins.pathExists (pkgsDir + "/${name}/systems.nix") then
                    import (pkgsDir + "/${name}/systems.nix")
                  else
                    defaultSystems;
              }
            else
              builtins.abort "non directory found"
          ) pkgsList;

          systemPkgsList = map (
            {
              name,
              package,
              systems,
            }:
            let
              systemPackages = map (
                system:
                let
                  pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ overlay ];
                    config.allowUnfree = true;
                  };
                in
                {
                  name = system;
                  value = {
                    ${name} = pkgs.callPackage package { };
                  };
                }
              ) systems;
            in
            builtins.listToAttrs systemPackages
          ) parsedPkgs;
        in
        builtins.foldl' nixpkgs.lib.recursiveUpdate { } systemPkgsList;

      eachSystem = nixpkgs.lib.genAttrs defaultSystems;
      overlay =
        next: prev:
        let
          system = prev.stdenv.hostPlatform.system;
        in
        {
          unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfree = prev.config.allowUnfree;
          };

          zig = inputs.zig.packages.${system};

          my = myPkgs.${system};

          fjordlauncher = inputs.fjordlauncher.packages.${system}.default;
        };

      extraHome =
        path:
        if (builtins.pathExists ./hosts/${path}/home.nix) then import ./hosts/${path}/home.nix else { };

      mkHost =
        path:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            extraHome = extraHome path;
          };
          modules = [
            ./hosts/${path}
            ./modules
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.catppuccin.nixosModules.catppuccin
            inputs.niri.nixosModules.niri
            inputs.home-manager.nixosModules.default
            {
              nixpkgs.overlays = [
                (import inputs.emacs-overlay)
                overlay
                (_: prev: {
                  gdm = prev.my.gdm-wam;
                })
              ];
            }
          ];
        };

      mkHosts =
        hosts:
        builtins.listToAttrs (
          map (host: {
            name = host;
            value = mkHost host;
          }) hosts
        );
    in
    {
      nixosConfigurations = mkHosts [
        "DESKTOP-VKFSNVPI"
        "amanojaku"
        "lionels-laptop"
        "vm"
        "live"
      ];

      packages = myPkgs;

      formatter = forAllSystems (system: pkgs: pkgs.nixfmt-rfc-style);

      devShells = forAllSystems (
        system: pkgs: {
          default = import ./devshells {
            pkgs = pkgs.extend overlay;
          };
        }
      );
    };
}
