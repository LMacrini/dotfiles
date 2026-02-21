{
  flake.nixosModules.base = {
    boot.tmp.cleanOnBoot = true;

    programs = {
      nano.enable = false;
      vim = {
        enable = true;
        defaultEditor = true;
      };
    };
  };
}
