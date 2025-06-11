{pkgs, ...}:
{
  xdg.desktopEntries = {
    iwtc = {
      name = "I WANT TO CRAFT";
      startupNotify = false;
      terminal = false;
      exec = "${pkgs.prismlauncher}/bin/prismlauncher -l \"I WANT TO CRAFT\" -s mc.serversmp.xyz:25565";
    };
  };
}
