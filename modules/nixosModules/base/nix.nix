{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.base = {self', ...}: {
    nixpkgs.overlays = [
      inputs.nur.overlays.default
      (final: prev: {
        prince = prev.nur.repos.forkprince;
      })
    ];

    environment.etc."programs.sqlite".source = "${inputs.nixpkgs}/programs.sqlite";

    nix = {
      channel.enable = false;

      optimise.automatic = true;

      registry = {
        config.flake = self;
        nixpkgs.flake = inputs.nixpkgs;
        zig.flake = inputs.zig;
      };

      settings = {
        experimental-features = "nix-command flakes pipe-operators";
        trusted-users = [
          "root"
          "lioma"
          "@wheel"
        ];

        keep-outputs = true; # direnv
        warn-dirty = false;
        builders-use-substitutes = true;
      };
    };
  };
}
