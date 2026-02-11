{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.jujutsu =
      (inputs.wrappers.wrapperModules.jujutsu.apply {
        inherit pkgs;
        settings = {
          user = {
            email = "seijamail@duck.com";
            name = "Seija";
          };

          ui = {
            default-command = "log";
            diff-editor = ":builtin";
            paginate = "never";
          };
        };
      }).wrapper;
  };
}
