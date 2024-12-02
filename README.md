# My NixOS configuration

You can automatically install this configuration on a new NixOS system by running
```bash
curl https://raw.githubusercontent.com/LMacrini/nixos/refs/heads/main/init.sh | sudo bash
```

You can then switch your configuration with
```bash
sudo nixos-rebuild switch --flake /etc/nixos#default
```

**Do not try this, it has not been tested yet**
