#!/usr/bin/env bash
set -euo pipefail

yorn() {
    local var=$1
    local default=$2
    local prompt=$3
    local input

    while true; do
        read -rp "$prompt " input
        input="${input,,}" # Convert to lowercase

        if [[ -z "$input" && -n "$default" ]]; then
            input="$default"
        fi

        case "$input" in
            y|yes|true|1) 
              declare -g $var=true
              return 0
              ;;
            n|no|false|0)
              declare -g $var=false
              return 0
              ;;
            *) echo "Please enter y or n" ;;
        esac
    done
}

if curl -s --head https://github.com | grep "200" > /dev/null; then
  echo "Connected to the internet!"
else
  echo "Please connect to the internet. If you are connected, github may be down. Please try again later."
  exit 1
fi

if [ -d /tmp/config ]; then
  rm -r /tmp/config
fi
git clone https://github.com/lmacrini/dotfiles /tmp/config
cd /tmp/config

yorn manualdrives "n" "Do you want to partition drives manually? [n]"
if $manualdrives; then
  echo "Just run 'exit' when you're done to proceed"
  echo "(make sure to mount boot on /mnt/boot and the main partition on /mnt)"
  sudo -i
else
  echo ""
  lsblk
  echo ""

  while true; do
    read -p "Please choose which drive you want to install nix on: " drive

    if [[ -e /dev/$drive ]]; then
      yorn sure "n" "Are you sure you want to continue? This will wipe all information on the drive [n]"
      if $sure; then
        break
      fi
    else
      echo "invalid drive, please try again"
    fi
  done


  yorn swap "n" "Do you want a swap file? [n]"
  if $swap; then
    default_ram=$(free -g | awk '/^Mem:/ {print $2}')
    read -p "How big do you want your swap file? (in GiB, default=$default_ram): " swapsize
    swapsize=${swapsize:=$default_ram}
    while [[ $swapsize -gt 32 ]] || [[ $swapsize -gt $(($default_ram*2)) ]]; do
      read -p "Invalid input, please try again " swapsize
      swapsize=${swapsize:=$default_ram}
    done

    sudo disko -m destroy,format,mount --yes-wipe-all-disks --arg disk "\"/dev/${drive}\"" --arg swap "\"${swapsize}\"" ./disko/swap.nix
  else
    sudo disko -m destroy,format,mount --yes-wipe-all-disks --arg disk "\"/dev/${drive}\"" ./disko/no-swap.nix
  fi
fi

echo ""

while true; do
  read -p "Which host do you want to build? " host

  if [[ $host == "new" ]]; then
    sudo -i
    continue
  fi

  if [[ -f "./hosts/$host/hardware-configuration.nix" ]]; then
    yorn replacehardware "n" "hardware-configuration.nix found in this host, do you wish to replace it? [n]"
  else
    replacehardware=true
  fi

  if $replacehardware; then
    nixos-generate-config --root /mnt --show-hardware-config > ./hosts/$host/hardware-configuration.nix
    sudo git add .
  fi

  if sudo nixos-install --flake "./#$host" --no-channel-copy; then
    break
  fi

  echo ""
  echo "Build failed, please try again"
done

echo ""
echo "Setting up password for lioma: "
sudo nixos-enter --root /mnt -c 'passwd lioma'

cp -r . /mnt/home/lioma/dotfiles
sudo chown -R lioma /mnt/home/lioma/dotfiles

echo ""
echo "Build complete, you may reboot"
