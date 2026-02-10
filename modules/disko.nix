{
  perSystem = {inputs', ...}: {
    packages.disko = inputs'.disko.packages.disko-install;
  };
}
