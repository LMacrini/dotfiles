{ lib, ... }:
{
  options = with lib; {
    liveSystem = mkOption {
      default = false;
      example = true;
      type = types.bool;
    };

    stateVersion = mkOption {
      type = types.str;
    };

    guiApps = mkEnableOption "gui apps" // {
      default = true;
    };

    mainUser = mkOption {
      default = "lioma";
      type = types.str;
    };
  };
}
