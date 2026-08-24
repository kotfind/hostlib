{
  outputs = {...}: {
    nixosModules.default = import ./modules/shared.nix;
  };
}
