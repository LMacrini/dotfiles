{lib, ...}: {
  options = with lib; {
    liveSystem = mkOption {
      default = false;
      example = true;
      type = types.bool;
    };
    stateVersion = mkOption {
      type = types.str;
    };
  };
}
