{
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    packages.install = pkgs.writeShellScriptBin "install" ''
      ${inputs'.disko.packages.disko-install} --flake $1 --disk main $2
    '';
  };
}
