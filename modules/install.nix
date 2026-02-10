{lib, ...}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    packages.install = pkgs.writeShellScriptBin "install" ''
      exec ${lib.getExe inputs'.disko.packages.disko-install} --write-efi-boot-entries --flake $1 --disk main $2
    '';
  };
}
