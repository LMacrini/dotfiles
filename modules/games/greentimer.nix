{lib, config, pkgs, ...}: {
	options = {
		greentimer.enable = lib.mkEnableOption "Enables green timer";
	};

	config = mkIf config.greentimer.enable {
		users.users.lioma.packages = with pkgs; [
			urn-timer
		];
	};
}