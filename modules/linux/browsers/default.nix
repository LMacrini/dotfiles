{lib, config, ...}: {
  imports = [
    ./floorp.nix
    ./ungoogled-chromium.nix
  ];

  options = {
    browsers.all.enable = lib.mkEnableOption "Enables all browsers unless explicitly changed";
  };

  config = {
    browsers = {
      all.enable = lib.mkDefault false;
      floorp.enable = lib.mkDefault true;
      ungoogled-chromium.enable = lib.mkDefault config.browsers.all.enable;
    };
  };
}
