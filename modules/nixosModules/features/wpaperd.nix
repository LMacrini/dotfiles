{lib, ...}: {
  flake.aspects.wpaperd.deps = [
    "hjem"
    "wallpaper"
  ];

  flake.aspects.wpaperd.module = {pkgs, ...}: let
    tomlFormat = pkgs.formats.toml {};

    mod = {config, ...}: {
      systemd.services.wpaperd = let
        conf = tomlFormat.generate "wpaperd.toml" {
          any.path = "${config.wallpaper.image}";
        };
      in {
        enable = true;

        description = "wpaperd wallpaper daemon";
        documentation = ["https://github.com/danyspin97/wpaperd"];
        partOf = [config.wayland.systemd.target];
        after = [config.wayland.systemd.target];
        wantedBy = [config.wayland.systemd.target];

        restartTriggers = [conf];

        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = 2;
          ExecStart = "${lib.getExe pkgs.wpaperd} -c ${conf}";
        };
      };
    };
  in {
    hjem.extraModules = [mod];
  };
}
