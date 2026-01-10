{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = with lib; {
    fonts.nerdfont = {
      name = mkOption {
        default = "JetBrainsMono NFM";
        type = types.str;
      };

      nlName = mkOption {
        default =
          if config.fonts.nerdfont.name == "JetBrainsMono NFM" then
            "JetBrainsMonoNL NFM"
          else
            config.fonts.nerdfont.name;
        type = types.str;
      };

      propName = mkOption {
        default =
          if config.fonts.nerdfont.name == "JetBrainsMono NFM" then
            "JetBrainsMonoNL NFP"
          else
            config.fonts.nerdfont.name;
        type = types.str;
      };

      package = mkOption {
        default = pkgs.nerd-fonts.jetbrains-mono;
        type = types.package;
      };
    };
  };

  config = {
    fonts.packages = [
      config.fonts.nerdfont.package
    ];
  };
}
