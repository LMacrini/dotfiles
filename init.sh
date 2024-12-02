#!/bin/bash

cd /etc/nixos

sudo curl -L -o nixos.tar.gz "https://github.com/LMacrini/nixos/archive/refs/heads/main.tar.gz"
sudo gunzip nixos.tar.gz
sudo tar -xf nixos.tar
sudo rm nixos.tar

# Extract the section from the source file
awk '/# Bootloader\./ {print_line=1} print_line && /^[[:space:]]*$/ {print_line=0} print_line {print}' configuration.nix > section.tmp

sudo mv nixos-main/* ./
sudo mv nixos-main/.config ./
sudo rm -r nixos-main init.sh README.md

sed -i "s/lioma/$USER/g" configuration.nix home.nix

if [[ -z "$(<section.tmp)" ]]; then
  printf "No bootloader found in source file, \e[1;33mplease be careful\e[0m\n"
else
  sudo sed -i '$!s@$@\\@g' section.tmp
  sudo sed -i "/# Bootloader\./,/^[[:space:]]*$/c\\$(<section.tmp)\n" configuration.nix

  echo "Bootloader section replaced successfully."
fi
rm section.tmp
