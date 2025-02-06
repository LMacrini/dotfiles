{
  inputs,
  pkgs,
  modulesPath,
  ...
}: let
  nixinstall = pkgs.writeTextFile {
    name = "nixinstall";
    executable = true;
    destination = "/bin/nixinstall";
    text = builtins.readFile ./script.sh;
  };
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = with pkgs; [
    git
    iwd
    # inputs.install-script.packages.x86_64-linux.nixinstall
    nixinstall
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
}
