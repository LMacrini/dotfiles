{
  flake.aspects.general = {
    deps = [
      "discord"
    ];

    module = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.librewolf
      ];
    };
  };
}
