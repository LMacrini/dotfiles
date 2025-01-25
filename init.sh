#!/usr/bin/env bash

if [ -d "~/dotfiles" ]; then
  echo "dotfiles directory found, making backup..."
  TIMESTAMP=$(date +"%FT%H%M%S")
  mv ~/dotfiles "~/dotfiles_$TIMESTAMP"
  echo "Backup complete, proceeding"
fi

mkdir ~/dotfiles
cd dotfiles

nix-shell -p git --run "
git clone https://github.com/lmacrini/nixos --recursive .
"

echo 'nix run github:lmacrini/nvf-config --extra-experimental-features "nix-command flakes"' > vim.sh
chmod +x vim.sh

cat << 'EOF' > hdw.sh
nix-shell -p git --run "
cp /etc/nixos/hardware-configuration.nix ./hosts/$1
git add ./hosts/$1/hardware-configuration.nix
"
EOF
chmod +x hdw.sh

cat << 'EOF' > build.sh
nix-shell -p nh nom nvd nerd-fonts.fira-code --run "
if nh os boot . -H $1 -- --extra-experimental-features 'nix-command flakes'; then
  echo Build successful, rebooting in 5 seconds...
  sleep 5
  rm build.sh vim.sh hdw.sh
  reboot
else
  echo Build unsuccessful, not rebooting
fi
"
EOF
chmod +x build.sh

echo "Setup succesful, run 'vim.sh' to open neovim for editing or run 'build.sh host' to build specified host"
