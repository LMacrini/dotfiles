{pkgs, ...}:
pkgs.writeTextFile {
  name = "buildiso";
  executable = true;
  destination = "/bin/buildiso";
  text = builtins.readFile ./buildiso.sh;
}
