{lib, ...}: {
  options = with lib; {
    guiApps = mkEnableOption "gui apps" // {default = true;};
  };
}
