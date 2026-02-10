{lib, ...}: {
  perSystem = {
    pkgs,
    inputs',
    self',
    ...
  }: {
    packages.installVm = pkgs.writeShellScriptBin "install-vm" ''
      sudo ${lib.getExe inputs'.packages.disko} -m destroy,format,mount --yes-wipe-all-disks --arg disk ${./_disko.nix} $1

      HARDWARE=./modules/hosts/vm/hardware-configuration.nix
      {
        echo "{flake.nixosModules.vmHost="
        nixos-generate-config --root /mnt --show-hardware-config
        echo "};}"
      } > $HARDWARE
      git add $HARDWARE
      ${self'.formatter} $HARDWARE

      sudo nixos-install --flake .#vm --no-channel-copy
    '';
  };
}
