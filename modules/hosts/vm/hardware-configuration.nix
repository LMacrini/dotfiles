{
  flake.nixosModules.vmHost = {
    fileSystems."/" = {
      device = "REPLACEME";
      fsType = "ext4";
    };
  };
}
