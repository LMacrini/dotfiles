{
  pkgs,
  inputs,
  ...
}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    inputs.neovim.packages.aarch64-darwin.default
  ];

  environment.variables = {
    EDITOR = "vim";
  };

  # Necessary for using flakes on this system.
  # nix.settings = {
  #   experimental-features = "nix-command flakes";
  #   trusted-users = [
  #     "root"
  #     "lionel"
  #   ];
  # };

  mainUser = "lionel";

  nix.optimise.automatic = true;

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  home-manager.backupFileExtension = "backup";
}
