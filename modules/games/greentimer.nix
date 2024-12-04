{lib, config, pkgs, ...}: {
	options = {
		greentimer.enable = lib.mkEnableOption "Enables green timer";
	};

	config = {
		users.users.lioma.packages = with pkgs; [
			urn-timer
		];
	};
}