{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  networking.hostName = "DESKTOP-VKFSNVPI"; # Define your hostname.

  games.enable = true;
  obs.enable = true;

  vms.enable = true;
}