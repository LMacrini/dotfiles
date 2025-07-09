{
  pkgs,
  config,
  lib,
  ...
}: {
  options = with lib; {
    shell = mkOption {
      default = "bash";
      type = types.enum [
        "bash"
        "fish"
        "nu"
        "zsh"
      ];
      example = "zsh";
      description = "system shell";
    };
  };

  config = let
    map = set: str: set.${str};
    shellPkg =
      map {
        "bash" = pkgs.bash;
        "fish" = pkgs.fish;
        "nu" = pkgs.nushell;
        "zsh" = pkgs.zsh;
      }
      config.shell;
  in {
    users = {
      # defaultUserShell = shellPkg;
      users = {
        lioma.shell = shellPkg;
      };
    };

    programs = {
      zsh.enable = lib.mkDefault (config.shell == "zsh");
      fish.enable = lib.mkDefault (config.shell == "fish");
    };

    environment.systemPackages = lib.mkIf (!(lib.elem config.shell ["bash" "fish" "zsh"])) [
      shellPkg
    ];

    environment.shells = [shellPkg];
  };
}
