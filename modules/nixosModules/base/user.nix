{self, ...}: {
  flake.nixosModules.base = {pkgs, ...}: {
    users.mutableUsers = false;

    users.users.lioma = {
      isNormalUser = true;
      description = "Lionel Macrini";
      extraGroups = [
        "input"
        "networkmanager"
        "uinput"
        "wheel"
        "video"
      ];
      hashedPassword = "$y$j9T$MVARZZBLm43XHuw9mceTd1$Ij0wQ0GJ5YwJinZlm0e4IWK2Bq8VHN/Kbe3xvQ58B22";

      shell = self.packages.${pkgs.stdenv.system}.environment;
    };
  };
}
