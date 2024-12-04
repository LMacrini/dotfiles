{config, lib, pkgs, ...} : {
  
  imports = [
	../../modules
	];
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "DESKTOP-VKFSNVPI"; # Define your hostname.

  games.enable = true;
  launchers.enable = true;
  lightGames.enable = true;
}