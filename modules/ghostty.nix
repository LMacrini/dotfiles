{lib, pkgs, config, inputs, ...}: {
  options = {
    ghosttyflake.enable = lib.mkEnableOption "Enable ghostty flake";
  };

  config.environment.systemPackages = 
    if config.ghosttyflake.enable then
      [inputs.ghostty.packages.x86_64-linux.default]
    else
      [pkgs.unstable.ghostty];
}
