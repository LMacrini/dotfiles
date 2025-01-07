{lib, ...}:
{
  imports = [
	./amd.nix
  ];

  gpu.amd.enable = lib.mkDefault false;
}