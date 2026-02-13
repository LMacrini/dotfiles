{lib, ...}: {
  flake.nixosModules.base = {
    pkgs,
    config,
    ...
  }: {
    options = {
      kanata.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enables kanata";
      };
    };

    config = lib.mkIf config.kanata.enable {
      systemd.user.services.kanata = {
        description = "Run kanata";
        before = ["display-manager.service" "getty.target"];
        after = ["systemd-udev-settle.service"];
        wants = ["systemd-udev-settle.service"];

        serviceConfig = {
          ExecStart = "${pkgs.self.kanata}";
          Type = "simple";
          Restart = "always";
          RestartSec = 2;
        };

        wantedBy = ["sysinit.target"];

        unitConfig = {
          DefaultDependencies = false;
        };
      };
    };
  };
}
