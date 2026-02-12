{self, ...}: {
  flake.nixosModules.desktop = {pkgs, ...}: {
    imports = [
      self.nixosModules.base
    ];

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
