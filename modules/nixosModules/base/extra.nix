{lib, ...}: {
  flake.nixosModules.base = {pkgs, ...}: {
    boot.tmp.cleanOnBoot = true;

    services.openssh.settings.UseDns = lib.mkDefault true;

    programs = {
      gdk-pixbuf.modulePackages = [
        pkgs.librsvg
      ];
      nano.enable = false;
      vim = {
        enable = true;
        defaultEditor = true;
      };
    };

    environment = {
      sessionVariables = {
        DO_NOT_TRACK = 1;
        DETSYS_IDS_TELEMETRY = "disabled";
      };

      localBinInPath = true;
    };
  };
}
