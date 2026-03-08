{
  flake.aspects.general = {
    deps = [
      "discord"
      "browser"
    ];

    module = {pkgs, ...}: {};
  };
}
