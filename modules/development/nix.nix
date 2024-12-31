{lib, config, pkgs, ...}: {
	options = {
		dev.nix.enable = lib.mkEnableOption "Enables nix";
	};

	config = lib.mkIf config.dev.nix.enable {
		environment.systemPackages = with pkgs; [
			nixd
		];
	};
}