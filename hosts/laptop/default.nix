{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  networking.hostName = "Ordinateur-de-Lionel";

  lightGames.enable = true;
  greentimer.enable = false;

  tlp.enable = true;

  libreoffice.enable = true;
}
