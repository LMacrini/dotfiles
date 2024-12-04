{ config, pkgs, lib, ... }: {
  imports = [
    ./games.nix
    ./launchers.nix
    ./light-games.nix
    ./greentimer.nix
  ];

  games.enable = lib.mkDefault false;
  launchers.enable = lib.mkDefault false;
  lightGames.enable = lib.mkDefault false;
  greentimer.enable = lib.mkDefault (config.games.enable || config.launchers.enable || config.lightGames.enable);
}