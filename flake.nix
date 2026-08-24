{
  outputs = {...}: {
    nixosModules.default = import ./modules/os.nix;
  };
}
