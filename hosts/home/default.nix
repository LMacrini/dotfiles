{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  networking.hostName = "DESKTOP-VKFSNVPI"; # Define your hostname.

  configapps.enable = true;

  games.enable = true;
  obs.enable = true;

  vms.enable = true;

  libreoffice.enable = true;
}