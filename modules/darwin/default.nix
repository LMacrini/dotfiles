{config, ...}: let
  home = "/Users/${config.mainUser}";
in {
  users.users."${config.mainUser}" = {
    name = config.mainUser;
    inherit home;
  };

  environment = {
    variables = {
      NH_FLAKE = home + "/dotfiles";
    };
  };
}
