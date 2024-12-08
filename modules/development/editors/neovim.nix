{lib, config, pkgs, ...}: {
	options = {
		dev.editors.neovim.enable = lib.mkEnableOption "Enables neovim";
	};

	config = lib.mkIf config.dev.editors.enable {
		environment.systemPackages = with pkgs; [
			neovim
		];
	};
}