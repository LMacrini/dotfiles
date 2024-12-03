{ config, pkgs, ... }:

{
  programs.steam.enable = true;
  users.users.lioma.packages = with pkgs; [
	lutris
	unstable.osu-lazer-bin
	atlauncher
	aaaaxy
  ];
}