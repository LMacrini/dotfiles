{self, ...}: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nasin-nanpa-helvetica
      ];

      fontconfig.defaultFonts = {
        monospace = [
          "JetBrainsMonoNL NFM"
        ];
      };
    };
  };
}
