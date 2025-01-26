{ pkgs, lib, config, ... }: {
  options = {
    de.sway.enable = lib.mkEnableOption "Enable sway";
  };

  config = lib.mkIf config.de.sway.enable {
    environment.systemPackages = with pkgs; [
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      mako # notification system developed by swaywm maintainer
    ];

    # Enable the gnome-keyring secrets vault. 
    # Will be exposed through DBus to programs willing to store secrets.
    services.gnome.gnome-keyring.enable = true;
  };
}
