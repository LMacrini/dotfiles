{config, ...}: {
  users.users."${config.mainUser}" = {
    name = config.mainUser;
    home = "/Users/${config.mainUser}";
  };
}
