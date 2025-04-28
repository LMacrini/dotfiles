{lib, ...}: {
  options = {
    kb.cmk-dh.enable = lib.mkEnableOption "Enable colemak dh";
  };

  config = {
    kb.cmk-dh.enable = lib.mkDefault true;
  };
}
