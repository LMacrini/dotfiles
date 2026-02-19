{
  flake.nixosModules.ly = {
    services.displayManager.ly = {
      enable = true;
      settings = {
        xinitrc = "null";
        animation = "colormix";
      };
    };
  };
}
