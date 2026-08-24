{
  outputs = {...}: {
    nixosModules.default = import ./modules/os.nix;

    homeManagerModules.default = import ./modules/home.nix;

    lib = import ./modules/lib.nix;
  };
}
