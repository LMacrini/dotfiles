{
  lib,
  config,
  ...
}: {
  options = with lib; {
    de.sway.enable = mkEnableOption "sway";
    de.sway.output = mkOption {
      default = [];
      type = with types; attrsOf (attrsOf str);
    };
  };

  config = lib.mkIf config.de.sway.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
