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

      jj git clone https://git.serversmp.xyz/seija/dotfiles

      sudo ${lib.getExe inputs'.disko.packages.disko} -m destroy,format,mount --yes-wipe-all-disks --arg disk \"$1\" ${./_disko.nix}

      HARDWARE=./modules/hosts/vm/hardware-configuration.nix
      {
        echo "{flake.nixosModules.vmHost="
        nixos-generate-config --root /mnt --show-hardware-config
        echo ";}"
      } > $HARDWARE
      jj git export
      ${lib.getExe self'.formatter} $HARDWARE

      echo "\n\n" | sudo nixos-install --flake .#vm --no-channel-copy

      conf_dir="/mnt''${NH_FLAKE:-/home/lioma/seiconf}"

      sudo cp -r . $conf_dir
      sudo chown --recursive lioma $conf_dir
    '';
  };
}
