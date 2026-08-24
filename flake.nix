{
  outputs = {...}: {
    nixosModules.default = import ./modules/os.nix;

    homeManagerModules.default = import ./modules/home.nix;
  };
}
