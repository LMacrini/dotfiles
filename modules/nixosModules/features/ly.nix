{
  flake.aspects.ly.module = {
    services.displayManager.ly = {
      enable = true;
      settings = {
        animation = "colormix";
      };
    };
  };
}
