{lib, ...}: {
  perSystem = {pkgs, inputs', ...}: {
    packages.disko = pkgs.writeShellScriptBin "disko" ''
      exec sudo ${lib.getExe inputs'.packages.disko} -m destroy,format,mount --yes-wipe-all-disks --arg disk $1 $2
    '';
  };
}
