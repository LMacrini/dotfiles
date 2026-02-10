{lib, ...}: {
  perSystem = {
    pkgs,
    inputs',
    self',
    ...
  }: {
    packages.installVm = pkgs.writeShellScriptBin "install-vm" ''
      set -euo pipefail

      sudo ${lib.getExe inputs'.disko.packages.disko} -m destroy,format,mount --yes-wipe-all-disks --arg disk \"$1\" ${./_disko.nix}

      HARDWARE=./modules/hosts/vm/hardware-configuration.nix
      {
        echo "{flake.nixosModules.vmHost="
        nixos-generate-config --root /mnt --show-hardware-config
        echo "};}"
      } > $HARDWARE
      git add $HARDWARE
      ${self'.formatter} $HARDWARE

      sudo nixos-install --flake .#vm --no-channel-copy

      sudo cp -r . /mnt/dotfiles
    '';
  };
}
