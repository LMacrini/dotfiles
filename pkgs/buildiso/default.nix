{pkgs, ...}:
pkgs.writeTextFile {
  name = "buildiso";
  executable = true;
  destination = "/bin/buildiso";
  text = ''
    #!/usr/bin/env bash
    nix build .#nixosConfigurations.live.config.system.build.isoImage |& nom
  '';
}
