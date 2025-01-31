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
  echo "Please connect to the internet with iwd. If you are connected, github may be down. Please try again later."
  exit 1
fi

yorn manualdrives "n" "Do you want to partition drives manually? [n]"
if manualdrives; then
  echo "Just run 'exit' when you're done to proceed"
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
    swapsize=${swapsize:=default_ram}
    while [[ $swapsize -gt 32 ]] || [[ $swapsize -gt $((default_ram*2)) ]]; do
      read -p "Invalid input, please try again " swapsize
      swapsize=${swapsize:=default_ram}
    done

    sudo parted /dev/$drive -- mklabel gpt
    sudo parted /dev/$drive -- mkpart root ext4 512MB -${swapsize}GB
    sudo parted /dev/$drive -- mkpart swap linux-swap -${swapsize}GB 100%
    sudo parted /dev/$drive -- mkpart ESP fat32 1MB 512MB
    sudo parted /dev/$drive -- set 3 esp on

    sudo mkfs.ext4 -L nixos /dev/${drive}1
    sudo mkswap -L swap /dev/${drive}2
    sudo mkfs.fat -F 32 -n boot /dev/${drive}3
  else
    sudo parted /dev/$drive -- mklabel gpt
    sudo parted /dev/$drive -- mkpart root ext4 512MB 100%
    sudo parted /dev/$drive -- mkpart ESP fat32 1MB 512MB
    sudo parted /dev/$drive -- set 2 esp on

    sudo mkfs.ext4 -L nixos /dev/${drive}1
    sudo mkfs.fat -F 32 -n boot /dev/${drive}2
  fi

  sudo mount /dev/disk/by-label/nixos /mnt
  sudo mkdir -p /mnt/boot
  sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

  echo "/dev/${drive}"
  if [[ $swap = true ]]; then
    yorn swapon "n" "Do you want to enable swap now? (recommended on lower end devices) [n]"
    if $swapon; then
      sudo swapon /dev/${drive}2
    fi
  fi

fi

sudo nixos-generate-config --root /mnt

cd /mnt/etc/nixos

sudo git clone https://github.com/lmacrini/nixos
cd nixos

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
    sudo cp ../hardware-configuration.nix "./hosts/$host"
    sudo git add .
  fi

  if sudo nixos-install --flake "./#$host"; then
    break
  fi

  echo ""
  echo "Build failed, please try again"
done

echo ""
echo "Setting up password for lioma: "
sudo nixos-enter --root /mnt -c 'passwd lioma'
echo ""
echo "Build complete, you may reboot"
