{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      blesh
    ];

    shellAliases = {
      cd = "z";
      cls = "clear";
      lg = "lazygit";
    };

    sessionVariables = {
      DO_NOT_TRACK = 1;
    };
  };

  programs = {
    btop.enable = true;

    carapace = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = true;
      enableZshIntegration = false;
    };

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
      environmentVariables = {
        NO_POINTER_VIEWPORT = 1;
      };

      shellAliases = {
        la = "ls -a";
        ll = "ls -l";
        lla = "ls -la";
      };

      settings = {
        show_banner = false;
      };
    };

    zsh = {
      enable = true;
    };

    home-manager.enable = true;
  };
}
