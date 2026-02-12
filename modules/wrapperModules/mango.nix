{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrapperModules.mango = inputs.wrappers.lib.wrapModule ({config, ...}: let
    pkgs = config.pkgs;

    autostart =
      pkgs.writeShellScriptBin "autostart.sh"
      # bash
      ''
        ${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd --all
        systemctl --user reset-failed
        systemd-inhibit --who="mangowc config" \
            --why="power button keybind" \
            --what=handle-power-key \
            --mode=block \
            sleep infinity \
            & echo $! > /tmp/.mangowc-systemd-inhibit
      '';

    launcher = "${lib.getExe pkgs.rofi} -show drun";
    sessionMenu = builtins.warn "TODO: wlogout" "";

    monitors =
      config.monitors
      |> lib.mapAttrsToList (n: v:
        with (lib.mapAttrs (_: toString) v); "monitorrule=name:${n},width:${width},height:${height},refresh:${refreshRate},x:${x},y:${y},scale:${scale}")
      |> builtins.concatStringsSep "\n";

    wpaperdConf = pkgs.writeText "wpaperd.toml" ''
      [any]
      path = "${config.wallpaper}"
    '';

    conf =
      pkgs.writeText "mango.conf"
      # conf
      ''
        exec-once = kitty
        exec-once = wpaperd -dc ${wpaperdConf}

        env = DISPLAY,:3
        exec = xwayland-satellite :3

        exec-once = ${autostart}

        trackpad_natural_scrolling = 1
        click_method = 2

        env = ELECTRON_OZONE_PLATFORM_HINT,wayland

        focuscolor = 0xff6ed4ff

        gesturebind = NONE,left,3,viewtoright_have_client
        gesturebind = NONE,right,3,viewtoleft_have_client
        switchbind = fold,spawn,systemctl suspend

        windowrule = isopensilent:1,isglobal:1,offsetx:100,offsety:100,appid:steam,title:^notificationtoasts_\d+_desktop$

        xkb_rules_layout = us
        xkb_rules_variant = mac

        bind = SUPER+SHIFT,S,spawn_shell,pkill slurp || grim -g "$(slurp -dw 0)" - | wl-copy

        bind = NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        bind = NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bind = NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bind = NONE,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        bind = NONE,XF86MonBrightnessUp,spawn,brightnessctl s 10%+
        bind = NONE,XF86MonBrightnessDown,spawn,brightnessctl s 10%-
        bind = NONE,XF86PowerOff,spawn,systemctl suspend

        bind = SUPER,space,spawn,fcitx5-remote -t

        bind = SUPER,Q,spawn,kitty
        bind = SUPER,T,spawn,${launcher}
        bind = ALT,space,spawn,${launcher}
        bind = SUPER,C,killclient
        bind = SUPER,Return,zoom
        bind = SUPER,L,spawn,${sessionMenu}

        bind = SUPER,N,focusstack,next
        bind = SUPER,E,focusstack,prev
        bind = SUPER,M,setmfact,-0.05
        bind = SUPER,I,setmfact,+0.05

        bind = SUPER,U,incnmaster,+1
        bind = SUPER,D,incnmaster,-1

        bind = SUPER,code:60,focusmon,right
        bind = SUPER+SHIFT,code:60,tagmon,right
        bind = SUPER,code:59,focusmon,left
        bind = SUPER+SHIFT,code:59,tagmon,left

        bind = SUPER,Up,focusdir,up
        bind = SUPER,Down,focusdir,down
        bind = SUPER,Left,focusdir,left
        bind = SUPER,Right,focusdir,right

        bind = SUPER+SHIFT,Up,exchange_client,up
        bind = SUPER+SHIFT,Down,exchange_client,down
        bind = SUPER+SHIFT,Left,exchange_client,left
        bind = SUPER+SHIFT,Right,exchange_client,right

        bind = SUPER,F,togglefullscreen
        bind = SUPER+SHIFT,F,togglefloating
        bind = SUPER+SHIFT,M,togglemaximizescreen

        bind = SUPER+SHIFT,T,setlayout,tile
        bind = SUPER,S,setlayout,scroller
        bind = SUPER+CTRL,M,setlayout,monocle

        scroller_proportion_preset = 0.3,0.5,0.7
        bind = SUPER,R,switch_proportion_preset

        bind = SUPER,Y,toggleoverview
        mousebind = SUPER,btn_left,moveresize,curmove
        mousebind = SUPER,btn_right,moveresize,curresize
        mousebind = NONE,btn_left,toggleoverview,-1
        mousebind = NONE,btn_right,killclient,0
        enable_hotarea = 0

        cursor_hide_timeout = 5
        new_is_master = 0
        smartgaps = 1
        drag_tile_to_tile = 1

        ${monitors}
      '';

    selfpkgs = self.packages.${pkgs.stdenv.system};
  in {
    options = with lib; {
      monitors = mkOption {
        default = {};

        type = self.lib.types.monitors;
      };

      wallpaper = mkOption {
        type = types.path;
      };
    };

    config = {
      package = inputs.mango.packages.${pkgs.stdenv.system}.default;

      extraPackages = with pkgs; [
        brightnessctl
        grim
        slurp
        wireplumber
        wl-clipboard
        wpaperd
        xwayland-satellite

        selfpkgs.kitty
      ];

      flags = {
        "-c" = "${conf}";
      };
    };
  });
}
