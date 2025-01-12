{lib, config, inputs, pkgs, ...}: {
	options = {
		dev.editors.neovim.enable = lib.mkEnableOption "Enables neovim";
	};

	config = lib.mkIf config.dev.editors.neovim.enable {
		environment.systemPackages = [
			inputs.neovim.packages.${pkgs.stdenv.hostPlatform.system}.default
		];
	};
}
