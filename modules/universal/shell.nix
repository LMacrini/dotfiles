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
        "zsh"
        "nu"
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
        "zsh" = pkgs.zsh;
        "nu" = pkgs.nushell;
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
      zsh.enable = lib.mkDefault config.shell == "zsh";
    };

    environment.systemPackages = lib.mkIf (!(lib.elem config.shell ["bash" "zsh"])) [
      shellPkg
    ];
  };
}
