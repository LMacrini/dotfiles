{lib, ...}: {
  options = with lib; {
    mainUser = mkOption {
      default = "lioma";
      type = types.str;
    };
  };
}
