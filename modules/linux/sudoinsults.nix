{
  lib,
  config,
  ...
}: {
  options = with lib; {
    sudoInsults.enable = mkEnableOption "sudo insults" // {default = true;};
  };

  config = lib.mkIf config.sudoInsults.enable {
    nixpkgs = {
      overlays = [
        (self: super: {
          sudo = super.sudo.override {
            withInsults = true;
          };
        })
      ];
    };
  };
}
