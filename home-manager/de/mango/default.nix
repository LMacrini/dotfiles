{
  pkgs,
  inputs,
  cfg,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.mango.hmModules.mango
  ];

  home.packages = with pkgs; [
    brightnessctl
    grim
    kanata
    nautilus
    slurp
    wireplumber
    wl-clipboard
    xwayland-satellite
  ];

  programs = {
    kitty.enable = true;
    rofi.enable = true;
    swaylock.enable = true;

    waybar = {
      enable = true;
      style = ./waybar.css;

      settings.mainBar = {
        modules-left = [
          "ext/workspaces"
          "dwl/window"
        ];

        "dwl/window" = {
          format = "  {title}";
          on-click = "activate";
          separate-outputs = true;

          rewrite = {
            " (.*) - YouTube — LibreWolf" = "   $1";
            "  NixOS Search - (.*) — LibreWolf" = "  󱄅 $1";
            " (.*) — LibreWolf" = "   $1";
          };
        };
      };
    };
  };

  services = {
    blueman-applet.enable = true;
    network-manager-applet.enable = true;
    swaync.enable = true;
    swayidle.enable = true;
    trash.enable = true;
    wayland-pipewire-idle-inhibit.enable = true;
    wpaperd.enable = true;
  };

  wayland.windowManager.mango = {
    enable = true;
    package = cfg.programs.mango.package;

    # HACK: causes autostart to be generated even if i don't have anything
    # to autostart
    autostart_sh = " ";

    settings =
      /* conf */ ''
        exec-once = kanata
        exec-once = kitty
        exec-once = waybar

        env = DISPLAY,:3
        exec = xwayland-satellite :3
        exec-once = ${config.xdg.configHome}/mango/autostart.sh

        trackpad_natural_scrolling = 1
        click_method = 2

        env = ELECTRON_OZONE_PLATFORM_HINT,wayland

        focuscolor = 0xff6ed4ff

        gesturebind = NONE,left,3,viewtoright_have_client
        gesturebind = NONE,right,3,viewtoleft_have_client
        switchbind = fold,spawn,systemctl suspend

        bind = SUPER+SHIFT,S,spawn_shell,pkill slurp || grim -g "$(slurp -dw 0)" - | wl-copy

        bind = NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        bind = NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bind = NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bind = NONE,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        bind = NONE,XF86MonBrightnessUp,spawn,brightnessctl s 10%+
        bind = NONE,XF86MonBrightnessDown,spawn,brightnessctl s 10%-

        bind = SUPER,Q,spawn,kitty
        bind = ALT,space,spawn_shell,rofi -show drun
        bind = SUPER,C,killclient
        bind = SUPER,Return,zoom

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
      ''
      + lib.concatStrings (
        builtins.genList (
          i:
          let
            tag = toString <| i + 1;
          in
          ''
            bind = SUPER,${tag},view,${tag}
            bind = SUPER+SHIFT,${tag},tag,${tag}
            bind = SUPER+CTRL,${tag},toggleview,${tag}
            bind = SUPER+CTRL+SHIFT,${tag},toggletag,${tag}
          ''
        ) 9
      )
      + cfg.de.mango.extraOptions;
  };
}
