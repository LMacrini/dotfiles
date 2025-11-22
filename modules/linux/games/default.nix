{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./games.nix
    ./launchers.nix
    ./light-games.nix
    ./tools.nix
    ./greentimer.nix
    ./emulators
  ];

  options = {
    games.enable = lib.mkEnableOption "Enables games";
    games.fixMAS = lib.mkEnableOption "the fix for the Monika After Story installer (probably et al)";
  };

  config = {
    games.standalone.enable = lib.mkDefault config.games.enable;
    games.launchers.enable = lib.mkDefault config.games.enable;
    games.light.enable = lib.mkDefault config.games.enable;

    games.tools.enable = lib.mkDefault config.games.launchers.enable;

    games.greentimer.enable = lib.mkDefault (
      config.games.standalone.enable || config.games.launchers.enable || config.games.light.enable
    );

    games.emulators.enable = lib.mkDefault false;

    programs.steam.package =
      lib.mkIf config.games.fixMAS
      <| pkgs.steam.override {
        extraLibraries = p: [
          p.openssl_1_1
        ];
      };

    nixpkgs.config.permittedInsecurePackages = lib.mkIf config.games.fixMAS [
      "openssl-1.1.1w"
    ];
  };
}
