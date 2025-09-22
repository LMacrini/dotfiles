{
  os,
  extraHome,
  cfg,
  lib,
  ...
}: {
  imports = [
    ./universal
    (./. + "/${os}")
    extraHome
  ];

  guiApps = lib.mkDefault cfg.guiApps;
}
