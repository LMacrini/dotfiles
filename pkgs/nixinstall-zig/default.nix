{ zig }:
zig.nightly.makePackage {
  pname = "nixinstall-zig";
  version = "0.2.0";
  src = ./.;
  zigReleaseMode = "safe";
  depsHash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
}
