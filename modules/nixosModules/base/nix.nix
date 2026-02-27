{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.base = {
    nixpkgs.overlays = [
      (final: prev: {
        self = self.packages.${prev.stdenv.system};
      })
      inputs.nur.overlays.default
    ];

    environment.etc."programs.sqlite".source = "${inputs.channel}/programs.sqlite";

    nix = {
      channel.enable = false;

      optimise.automatic = true;

      registry = {
        config.flake = self;
        nixpkgs.flake = inputs.nixpkgs;
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
