{pkgs, config, lib, ...}: {

	options = {
		games.enable = lib.mkEnableOption "Enables standalone games";
	};

	config = lib.mkIf config.games.enable {
		users.users.lioma.packages = with pkgs; [
			unstable.osu-lazer-bin
		];
	};
} 