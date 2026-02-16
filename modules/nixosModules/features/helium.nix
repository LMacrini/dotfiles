{
  flake.nixosModules.helium = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.nur.repos.forkprince.helium-nightly
    ];
  };
}
