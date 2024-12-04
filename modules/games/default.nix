{ config, pkgs, lib, ... }: {
  imports = [
    ./games.nix
    ./launchers.nix
    ./light-games.nix
  ];

 games.enable = lib.mkDefault false;
 launchers.enable = lib.mkDefault false;
 lightGames.enable = lib.mkDefault true;
}