{
  pkgs,
  inputs,
  cfg,
  config,
  lib,
  ...
}:
let
  useNoctalia = config.programs.noctalia-shell.enable;
in
{
  imports = [
    inputs.mango.hmModules.mango
    inputs.noctalia.homeModules.default
  ];

  home.packages =
    with pkgs;
    [
      brightnessctl
      grim
      kanata
      slurp
      wireplumber
      wl-clipboard
      xwayland-satellite
    ]
    ++ (with pkgs.kdePackages; [
      dolphin
      kde-cli-tools
      qtsvg
    ]);

  xdg.portal = {
    config.mango = {
      default = [
        "kde"
      ];

      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.ScreenShot" = "wlr";
    };

    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  gtk =
    let
      css = /* css */ ''
        headerbar.default-decoration {
          margin-bottom: 50px;
          margin-top: -100px;
        }

        window.csd,             /* gtk4? */
        window.csd decoration { /* gtk3 */
          box-shadow: none;
        }
      '';
    in
    {
      gtk3.extraCss = css;
      gtk4.extraCss = css;
    };

  qt =
    let
      catppuccinQtct = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "qt5ct";
        rev = "cb585307edebccf74b8ae8f66ea14f21e6666535";
        hash = "sha256-wDj6kQ2LQyMuEvTQP6NifYFdsDLT+fMCe3Fxr8S783w=";
      };

      qtct = {
        Appearance = {
          custom_palette = true;
          color_scheme_path = "${catppuccinQtct}/themes/catppuccin-macchiato-pink";
          icon_theme = "Papirus-Dark";
        };
      };
    in
    {
      enable = true;
      style.name = "kvantum";
      platformTheme.name = "qtct"; # TODO: 26.05, catppuccin-nix qt5ct

      qt5ctSettings = qtct;
      qt6ctSettings = qtct;

      kde.settings = {
        kdeglobals = {
          General = {
            TerminalApplication = "kitty";
          };

          Icons = {
            Theme = "Papirus-Dark";
          };

          "KFileDialog Settings" = {
            "Breadcrumb Navigation" = true;
          };
        };

        dolphinrc = {
          General = {
            ShowFullPath = true;
            ShowStatusBar = "FullWidth";
            RememberOpenedTabs = false;
            ShowSelectionToggle = false;
          };
        };
      };
    };

  xdg.configFile."xdg-desktop-portal-wlr/mango".text = /* ini */ ''
    [screencast]
    chooser_cmd = ${lib.getExe pkgs.bemenu} -bi
    chooser_type = dmenu
  '';

  xdg.configFile."menus/applications.menu".text =
    builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

  home.file.".cache/noctalia/wallpapers.json" = lib.mkIf useNoctalia {
    text = builtins.toJSON {
      defaultWallpaper = "${pkgs.my.imgs}/share/background.jpg";
    };
  };

  programs = {
    kitty.enable = true;
    rofi.enable = !useNoctalia;
    swaylock.enable = !useNoctalia;

    noctalia-shell = {
      enable = lib.mkDefault false;
      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];

        states = {
          kaomoji-provider = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
      };

      settings = {
        appLauncher = {
          terminalCommand = "kitty -e";
          enableSettingsSearch = false;
        };

        bar = {
          outerCorners = false;

          widgets = {
            left = [
              {
                id = "Workspace";
              }
            ];
            center = [
              {
                id = "Clock";
              }
            ];
            right = [
              {
                id = "MediaMini";
                maxWidth = 300;
              }
              {
                id = "Tray";
                blacklist = [
                  "Fcitx*"
                ];
                colorizeIcons = true;
                drawerEnabled = false;
                hidePassive = true;
              }
              {
                id = "NotificationHistory";
              }
              {
                id = "Volume";
              }
              {
                id = "Brightness";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "Network";
              }
              {
                id = "Battery";
                displayMode = "alwaysShow";
              }
              {
                id = "ControlCenter";
                icon = "";
                customIconPath = "${pkgs.my.imgs}/share/logo.png";
              }
            ];
          };
        };

        general = {
          enableShadows = false;
          compactLockScreen = true;
          allowPasswordWithFprintd = true;
          lockOnSuspend = false; # already handled by swayidle
        };

        controlCenter = {
          shortcuts = {
            left = [
              {
                id = "PowerProfile";
              }
              {
                id = "NoctaliaPerformance";
              }
            ];

            right = [
              {
                id = "KeepAwake";
              }
              {
                id = "NightLight";
              }
            ];
          };
        };

        colorSchemes.predefinedScheme = "Catppuccin";
        location = {
          name = lib.mkDefault "Ottawa, Canada";
          analogClockInCalendar = true;
          showCalendarWeather = false;
          firstDayOfWeek = 0;
        };

        dock.enabled = false;
      };
    };

    waybar = {
      enable = !useNoctalia;
      style = ./waybar.css;

      settings.mainBar = {
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
    };
  };

  services = {
    blueman-applet.enable = !useNoctalia;
    network-manager-applet.enable = !useNoctalia;
    swaync.enable = !useNoctalia;
    swayidle = {
      enable = true;
      events =
        let
          lockCmd = "${lib.getExe config.programs.noctalia-shell.package} ipc call lockScreen lock";
        in
        lib.mkIf useNoctalia [
          {
            event = "before-sleep";
            command = lockCmd;
          }
          {
            event = "lock";
            command = lockCmd;
          }
        ];
    };
    trash.enable = true;
    wayland-pipewire-idle-inhibit.enable = true;
    wpaperd.enable = !useNoctalia;
  };

  wayland.windowManager.mango = {
    enable = true;
    package = pkgs.emptyDirectory;

    systemd.variables = [
      "DISPLAY"
      "WAYLAND_DISPLAY"
      "XDG_CURRENT_DESKTOP"
      "XDG_SESSION_TYPE"
      "NIXOS_OZONE_WL"
      "XCURSOR_THEME"
      "XCURSOR_SIZE"
      "PATH"
    ];

    # HACK: causes autostart to be generated even if i don't have anything
    # to autostart
    autostart_sh = ''
      systemd-inhibit --who="mangowc config" \
          --why="power button keybind" \
          --what=handle-power-key \
          --mode=block \
          sleep infinity \
          & echo $! > /tmp/.mangowc-systemd-inhibit
    '';

    settings =
      let
        bar = if useNoctalia then "noctalia-shell" else "waybar";
        launcher = if useNoctalia then "noctalia-shell ipc call launcher toggle" else "rofi -show drun";
        sessionMenu =
          if useNoctalia then
            "noctalia-shell ipc call sessionMenu toggle"
          else
            builtins.warn "TODO: wlogout" "";
      in
      /* conf */ ''
        exec-once = kanata
        exec-once = kitty
        exec-once = ${bar}

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
