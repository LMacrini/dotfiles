{ pkgs, ... }:
pkgs.writeTextFile {
  name = "nixinstall";
  executable = true;
  destination = "/bin/nixinstall";
  text = builtins.readFile ./script.sh;
}
