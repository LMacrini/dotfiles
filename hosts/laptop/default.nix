{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  networking.hostName = "Ordinateur de Lionel";

  lightGames.enable = true;

  tlp.enable = true;
}