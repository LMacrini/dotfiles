{
  pkgs,
  lib,
  ...
}:
let
  buildFirefoxXpiAddon = lib.makeOverridable (
    {
      stdenv ? pkgs.stdenvNoCC,
      fetchurl ? pkgs.fetchurl,
      pname,
      version,
      addonId,
      url,
      sha256,
      meta,
      ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      passthru = { inherit addonId; };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );

  generatedPackages = import ./generated-addons.nix {
    inherit buildFirefoxXpiAddon;
    inherit (pkgs) fetchurl lib stdenv;
  };

  packages = generatedPackages // { };
in
packages
