{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  lightGames.enable = true;

  tlp.enable = true;
}