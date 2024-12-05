{pkgs, config, lib, ...}: {
  options = {
	configapps.enable = lib.mkEnableOption "Enables apps for configuring";
  };

  config = lib.mkIf config.configapps.enable {
	  environment.systemPackages = with pkgs; [
        dconf-editor
	    dconf2nix
	  ];
    };
}