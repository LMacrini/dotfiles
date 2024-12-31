{lib, config, ...}: {
	imports = [
		./editors
		./zig.nix
		./python.nix
		./unity.nix
		./nix.nix
	];

	options = {
		dev.enable = lib.mkEnableOption "Enables development tools";
	};

	config = {
		dev.editors.enable = lib.mkDefault config.dev.enable;
		dev.zig.enable = lib.mkDefault true;
		dev.python.enable = lib.mkDefault config.dev.enable;
		dev.nix.enable = lib.mkDefault config.dev.enable;
		dev.unity.enable = lib.mkDefault false;
	};
}