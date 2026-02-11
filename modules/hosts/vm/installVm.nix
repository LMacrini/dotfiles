{lib, ...}: {
  perSystem = {
    pkgs,
    inputs',
    self',
    ...
  }: {
    packages.installVm = pkgs.writeShellScriptBin "install-vm" ''
      set -euo pipefail

      : "''${1:?Usage: install-vm <disk>}"

      cd $(mktemp -d)
      git clone https://git.serversmp.xyz/seija/dotfiles .
      git checkout v2 # NOTE: temporary until v2 is the main branch

      sudo ${lib.getExe inputs'.disko.packages.disko} -m destroy,format,mount --yes-wipe-all-disks --arg disk \"$1\" ${./_disko.nix}

      HARDWARE=./modules/hosts/vm/hardware-configuration.nix
      {
        echo "{flake.nixosModules.vmHost="
        nixos-generate-config --root /mnt --show-hardware-config
        echo ";}"
      } > $HARDWARE
      git add $HARDWARE
      ${lib.getExe self'.formatter} $HARDWARE

      sudo nixos-install --flake .#vm --no-channel-copy

      sudo cp -r . /mnt/home/lioma/dotfiles
      sudo chown --recursive lioma /mnt/home/lioma/dotfiles
    '';
  };
}
