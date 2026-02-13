{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    config =
      # kbd
      ''
        (defcfg
          linux-dev-names-exclude (
            "ZSA Technology Labs Ergodox EZ"
            "ZSA Technology Labs Ergodox EZ Keyboard"
            "ZSA Technology Labs Ergodox EZ Consumer Control"
          )
          linux-continue-if-no-devs-found yes
          process-unmapped-keys false
        )

        (defsrc
          q w e r t y u i o p
          a s d f g h j k l ;
          z x c v b n m caps ralt rctl
        )


        (defalias nav
          (layer-while-held swap)
        )


        (deflayer cmkdh
          q w f p b j l u y ;
          a r s t g m n e i o
          x c d v z k h bspc ralt @nav
        )

        (deflayer qwerty
          q w e r t y u i o p
          a s d f g h j k l ;
          z x c v b n m bspc ralt @nav
        )

        (deflayer swap
          XX XX XX XX XX XX XX XX XX XX
          XX XX XX XX XX XX XX XX XX XX
          XX XX XX XX XX XX XX XX (switch
            ((base-layer cmkdh)) (layer-switch qwerty) break
            ((base-layer qwerty)) (layer-switch cmkdh) break
          ) XX
        )
      '';

    validatedConfig =
      pkgs.runCommand "kanata.kbd" {
        inherit config;
        passAsFile = ["config"];
        buildInputs = [pkgs.kanata];
      } ''
        kanata --check -c $configPath
        cp $configPath $out
      '';
  in {
    packages.kanata = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.kanata;
      flags = {
        "-c" = "${validatedConfig}";
      };
    };
  };
}
