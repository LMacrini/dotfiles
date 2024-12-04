{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  networking.hostName = "DESKTOP-VKFSNVPI"; # Define your hostname.

  games.enable = true;
  launchers.enable = true;
  lightGames.enable = true;
  greetimer.enable = true;
}