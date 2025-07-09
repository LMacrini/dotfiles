{gdm, replaceVars, my, ...}: let
  override = replaceVars ./org.gnome.login-screen.gschema.override {
    icon = "${my.icons}/share/logo.png";
  };
in gdm.overrideAttrs {
  preInstall = ''
    install -D ${override} "$DESTDIR/$out/share/glib-2.0/schemas/org.gnome.login-screen.gschema.override"
  '';
}
