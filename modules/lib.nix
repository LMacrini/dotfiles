{
  lib,
  self,
  inputs,
  ...
}: {
  flake.lib = {
    aspects = let
      getAll = aspects: aspects ++ map (aspect: self.aspects.${aspect}.deps |> getAll) aspects;
    in
      aspects:
        getAll aspects |> lib.flatten |> lib.uniqueStrings |> map (aspect: self.aspects.${aspect}.module);

    nixosSystem = {
      module,
      aspects ? [],
      system ? "x86_64-linux",
    }: let
      makePrime = a:
        a
        |> lib.filterAttrs (_: v: builtins.isAttrs v && builtins.hasAttr system v)
        |> builtins.mapAttrs (_: attr: attr.${system});
    in
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          [
            module
            self.nixosModules.base
            {
              config._module.args = {
                inherit system;
                inputs' =
                  builtins.mapAttrs (
                    _: flake: makePrime flake
                  )
                  inputs;
                self' = makePrime self;
              };
            }
          ]
          ++ self.lib.aspects aspects;
      };

    types = with lib; {
      monitors =
        types.attrsOf
        <| types.submodule {
          options = {
            width = mkOption {
              type = types.int;
              example = 1920;
              apply = toString;
            };

            height = mkOption {
              type = types.int;
              example = 1080;
              apply = toString;
            };

            refreshRate = mkOption {
              type = types.float;
              example = 144.0;
              apply = toString;
            };

            x = mkOption {
              type = types.int;
              default = 0;
              apply = toString;
            };

            y = mkOption {
              type = types.int;
              default = 0;
              apply = toString;
            };

            scale = mkOption {
              type = types.float;
              default = 1.0;
              apply = toString;
            };

            enabled = mkOption {
              type = types.bool;
              default = true;
            };
          };
        };

      systemd = {
        target = types.strMatching "[a-zA-Z0-9@%:_.\\-]+[.]target";
      };
    };
  };
}
