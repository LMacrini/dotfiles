{lib, ...}: {
  imports = [
    ./floorp.nix
    ./ungoogled-chromium.nix
  ];

  options = {
    browsers.all.enable = lib.mkEnableOption "Enables all browsers unless explicitly changed";
  };

  config = {
    browsers = {
      floorp.enable = lib.mkDefault true;
      ungoogled-chromium.enable = lib.mkDefault true;
    };
  };
}
