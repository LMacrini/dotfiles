{config, lib, pkgs, ...}: {
	options = {
		obs.enable = lib.mkEnableOption "Enable obs studio";
	};

	config = lib.mkIf config.obs.enable {
		users.users.lioma.packages = with pkgs; [
			obs-studio
		];
	};
}