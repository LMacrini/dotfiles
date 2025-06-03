{lib, ...}: {
  imports = [
    ./floorp.nix
    ./ungoogled-chromium.nix
  ];

  options = {
    browsers.all.enable = lib.mkEnableOption "Enables all browsers unless explicitly changed";
  };

  config = {
    browsers = rec {
      all.enable = lib.mkDefault false;
      floorp.enable = lib.mkDefault true;
      ungoogled-chromium.enable = lib.mkDefault all.enable;
    };
  };
}
