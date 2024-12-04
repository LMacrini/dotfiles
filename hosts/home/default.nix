{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  networking.hostName = "DESKTOP-VKFSNVPI"; # Define your hostname.

  games.enable = true;
  launchers.enable = true;
  lightGames.enable = true;
  greentimer.enable = true;
  obs.enable = true;

  vms.enable = true;
}