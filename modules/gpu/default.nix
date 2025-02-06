{lib, ...}: {
  imports = [
    ./amd.nix
    ./nvidia.nix
  ];

  gpu.amd.enable = lib.mkDefault false;
  gpu.nvidia.enable = lib.mkDefault false;
}
