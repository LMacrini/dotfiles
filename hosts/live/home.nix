{
  pkgs,
  lib,
  cfg,
  ...
}:
let
  hasDe = !(isNull cfg.de.de);
in
{
  home.packages = with pkgs; [
    kanata
  ];

  programs = {
    fish = {
      shellAbbrs = {
        startkanata = "kanata &> /dev/null &";
      };

      shellInitLast = lib.mkIf (!hasDe) ''
        echo The \"lioma\" and \"root\" accounts have empty passwords.
        echo
        echo To log in over ssh you must set a password for either \"lioma\" or \"root\"
        echo with `passwd` \(prefix with `sudo` for \"root\"\), or add your public key to
        echo /home/lioma/.ssh/authorized_keys or /root/.ssh/authorized_keys.
        echo
        echo To set up a wireless connection, run `nmtui`.
        echo Alternatively, use `nmcli device wifi` to list networks
        echo and use `nmcli device wifi connect \<ssid\> --ask` to connect to a network.
        echo
      '';
    };

    lsd.enable = lib.mkForce hasDe;
    starship.enable = lib.mkForce hasDe;

    zellij.settings = lib.mkIf (!hasDe) {
      pane_frames = false;
      simplified_ui = true;
      show_release_notes = false;
      ui.pane_frames = {
        hide_session_name = true;
        rounded_corners = false;
      };
    };
  };
}
