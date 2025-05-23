{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      blesh
    ];

    shellAliases = {
      cls = "clear";
      lg = "lazygit";
    };

    sessionVariables = {
      DO_NOT_TRACK = 1;
    };
  };

  programs = {
    btop.enable = true;

    direnv.enable = true;

    starship = {
      enable = true;
      settings = import ./starship.nix;
    };

    zoxide.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        source "$(blesh-share)/ble.sh"
      '';

      shellAliases = {
        cd = "z";
        ls = "lsd";
        la = "lsd -a";
        ll = "lsd -l";
        lla = "lsd -la";
        grep = "grep --color=auto";
      };

      sessionVariables = {
        NO_POINTER_VIEWPORT = 1;
      };
    };

    nushell = {
      enable = true;
      configFile = {
        source = ./nuconfig.nu;
      };
    };

    zsh = {
      enable = true;
    };

    home-manager.enable = true;
  };
}
