#!/bin/bash

cd /etc/nixos

curl -L -o nixos.zip "https://github.com/LMacrini/nixos/archive/refs/heads/main.zip"
unzip nixos.zip
rm nixos.zip

# Extract the section from the source file
awk '/# Bootloader\./ {print_line=1} print_line && /^[[:space:]]*$/ {print_line=0} print_line {print}' configuration.nix > section.tmp

mv nixos-main/* ./
mv nixos-main/.config ./
rm -r nixos-main init.sh README.md

if [[ -z "$(<section.tmp)" ]]; then
  printf "No bootloader found in source file, \e[1;33mplease be careful\e[0m\n"
else

gsed -i '$!s@$@\\@g' section.tmp

# Use sed to replace the same section in the target file
if sed --version >/dev/null 2>&1; then
    # GNU sed
    sed -i "/# Bootloader\./,/^[[:space:]]*$/c\\$(<section.tmp)\n" configuration.nix
else
    # BSD sed (macOS)
    gsed -i "/# Bootloader\./,/^[[:space:]]*$/c\\$(<section.tmp)\n" configuration.nix
fi

echo "Bootloader section replaced successfully.\n"
fi
rm section.tmp
