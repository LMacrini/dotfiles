{
  inputs,
  lib,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.swaylock =
      (inputs.wrappers.wrapperModules.swaylock.apply {
        package = lib.mkForce pkgs.swaylock-effects;
        inherit pkgs;
        settings = let
          catppuccin = lib.importJSON (pkgs.runCommand "converted.json" {nativeBuildInputs = [pkgs.jc];} ''
            jc --ini < ${inputs'.catppuccin.packages.swaylock}/macchiato.conf > $out
          '');
        in
          catppuccin
          // {
            clock = true;
            daemonize = true;
            effect-blur = "7x5";
            fade-in = 1;
            image = "${self.images}/background.jpg";
            indicator = true;
            ring-color = "717df1";
          };
      }).wrapper;
  };
}
