# My NixOS configuration

You can automatically install this configuration on a new NixOS system by running
```bash
curl https://raw.githubusercontent.com/LMacrini/nixos/refs/heads/main/init.sh | sudo bash
```

You can then switch your configuration with
```bash
sudo nixos-rebuild switch --flake /etc/nixos#default
```
After a reboot, your system should look just like mine.

**Do not try this, it has not been tested yet**\
(Also this is my config for the sake of my convenience,
please don't use it unless you're one of my friends)
