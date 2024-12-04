{pkgs, lib, config, ...} : {

  options = {
	lightGames.enable = lib.mkEnableOption "Enables light games";
  };

  config = lib.mkIf config.lightGames.enable {
	users.users.lioma.packages = with pkgs; [
	  aaaaxy
	];
  };
}