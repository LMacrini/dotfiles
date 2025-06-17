{config, ...}: let
  home = "/Users/${config.mainUser}";
in {
  users.users."${config.mainUser}" = {
    name = config.mainUser;
    inherit home;
  };

  system.primaryUser = config.mainUser;

  environment = {
    variables = {
      NH_FLAKE = home + "/dotfiles";
    };
  };
}
