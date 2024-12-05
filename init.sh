#!/bin/bash

cd /etc/nixos

sudo rm -r backups/*
sudo mkdir .backups
sudo mv ./* ./.backups
sudo mv ./.backups/hardware-configuration.nix ./

sudo curl -L -o nixos.tar.gz "https://github.com/LMacrini/nixos/archive/refs/heads/main.tar.gz"
sudo gunzip nixos.tar.gz
sudo tar -xf nixos.tar
sudo rm nixos.tar

sudo mv nixos-main/* ./
sudo mv nixos-main/.config ./
sudo rm -r nixos-main init.sh README.md

host=${1:-default}
rebuild_type=${2:-switch}
sudo nixos-rebuild $2 --flake "/etc/nixos#$host"
sudo reboot now
