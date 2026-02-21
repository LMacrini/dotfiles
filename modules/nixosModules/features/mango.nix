{
  self,
  inputs,
  lib,
  ...
}: {
  flake.aspects.mango.deps = [
    "desktop"
    "hjem"
    "ly"
    "swayidle"
    "wallpaper"
    "wayland-pipewire-idle-inhibit"
  ];

  flake.aspects.mango.module = {
    pkgs,
    config,
    ...
  }: let
    mango = inputs.mango.packages.${pkgs.stdenv.system}.mango.override {
      enableXWayland = false;
    };
  in {
    environment.systemPackages = [
      mango
      pkgs.self.kitty
    ];

    xdg.portal = {
      enable = true;

      config = {
        mango = {
          default = "gtk";

          "org.freedesktop.impl.portal.Inhibit" = [];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.ScreenShot" = "wlr";
          "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
        };
      };

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];

      wlr = {
        enable = true;
        settings = {
          screencast = {
            chooser_cmd = "${lib.getExe pkgs.bemenu} -bi";
            chooser_type = "dmenu";
          };
        };
      };

      configPackages = [mango];
    };

    security.polkit.enable = true; # should be on by default but doesn't hurt

    services = {
      displayManager.sessionPackages = [mango];
      graphical-desktop.enable = true;
      gnome.gnome-keyring.enable = true;
    };

    hjem.users.lioma = let
      autostart =
        pkgs.writeShellScriptBin "autostart.sh"
        # bash
        ''
          dbus-update-activation-environment --systemd --all
          systemctl --user reset-failed
          systemd-inhibit --who="mangowc config" \
              --why="power button keybind" \
              --what=handle-power-key \
              --mode=block \
              sleep infinity \
              & echo $! > /tmp/.mangowc-systemd-inhibit
        '';

      monitors =
        config.preferences.monitors
        |> lib.mapAttrsToList (n: v:
          with v; "monitorrule=name:${n},width:${width},height:${height},refresh:${refreshRate},x:${x},y:${y},scale:${scale}")
        |> builtins.concatStringsSep "\n";

      launcher = "rofi -show drun";
      sessionMenu = builtins.warn "TODO: wlogout" "wlogout";

      tomlFormat = pkgs.formats.toml {};
      wpaperdConf = tomlFormat.generate "wpaperd.toml" {
        any.path = "${config.wallpaper.image}";
      };

      waybar =
        (self.wrapperModules.waybar.apply {
          inherit pkgs;

          settings = {
            modules-left = [
              "ext/workspaces"
              "dwl/window"
            ];

            "ext/workspaces" = {
              on-click = "activate";
            };

            "dwl/window" = {
              format = "  {title}";
              rewrite = {
                " (.*) - YouTube — LibreWolf" = "   $1";
                "  NixOS Search - (.*) — LibreWolf" = "  󱄅 $1";
                " (.*) — LibreWolf" = "   $1";
              };
            };
          };

          "style.css".content =
            # css
            ''
              #workspaces button {
                border-radius: 0;
                box-shadow: inset 0px 2px 0px transparent;
                transition: box-shadow 0.2s ease;
              }

              #workspaces button.active {
                box-shadow: inset 0px 2px 0px white;
              }
            '';
        }).wrapper;
    in {
      packages = with pkgs; [
        rofi
        wlogout
        wpaperd

        pkgs.self.kitty
        waybar

        # redundant but technically i do use them
        dbus
        systemd
      ];

      rum.misc.gtk.css = let
        css =
          # css
          ''
            headerbar.default-decoration {
              margin-bottom: 50px;
              margin-top: -100px;
            }

            window.csd,             /* gtk4? */
            window.csd decoration { /* gtk3 */
              box-shadow: none;
            }
          '';
      in {
        gtk3 = css;
        gtk4 = css;
      };

      wayland.systemd.target = "mango-session.target";

      systemd.targets.mango-session = {
        after = ["graphical-session-pre.target"];
        bindsTo = ["graphical-session.target"];
        wants = ["graphical-session-pre.target"];
        description = "mango compositor session";
        documentation = ["man:systemd.special(7)"];
      };

      xdg.config.files."mango/config.conf".text =
        # conf
        ''
          exec-once = kitty
          exec-once = waybar
          exec-once = wpaperd -dc ${wpaperdConf}

          exec-once = ${lib.getExe pkgs.networkmanagerapplet}
          exec-once = ${lib.getExe' pkgs.blueman "blueman-applet"}

          env = DISPLAY,:3
          exec = xwayland-satellite :3

          exec-once = ${lib.getExe autostart}

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
          ${lib.concatStrings
            <| builtins.genList (
              i: let
                tag = toString <| i + 1;
              in ''
                bind=SUPER,${tag},view,${tag}
                bind=SUPER+SHIFT,${tag},tag,${tag}
                bind=SUPER+CTRL,${tag},toggleview,${tag}
                bind=SUPER+CTRL+SHIFT,${tag},toggletag,${tag}
              ''
            )
            9}
        '';
    };
  };
}
