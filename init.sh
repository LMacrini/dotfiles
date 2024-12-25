#!/bin/bash

cd /etc/nixos

sudo rm -r backups/*
sudo mkdir .backups
sudo mv ./* ./.backups
sudo mv ./.backups/hardware-configuration.nix ./

sudo nix-shell -p git --run "
git clone https://github.com/lmacrini/nixos --recursive
"

sudo mv nixos/* .
sudo rm -r nixos init.sh README.md

host=${1:-default}
rebuild_type=${2:-switch}
sudo nixos-rebuild $rebuild_type --flake "/etc/nixos#$host"
sudo reboot now
