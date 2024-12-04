#!/bin/bash

cd /etc/nixos

sudo mkdir backups
sudo cp ./* ./backups

sudo curl -L -o nixos.tar.gz "https://github.com/LMacrini/nixos/archive/refs/heads/main.tar.gz"
sudo gunzip nixos.tar.gz
sudo tar -xf nixos.tar
sudo rm nixos.tar

sudo mv nixos-main/* ./
sudo mv nixos-main/.config ./
sudo rm -r nixos-main init.sh README.md

host="${1:-${host:-default}}"
sudo nixos-rebuild switch --flake "/etc/nixos#$host"
sudo reboot now
