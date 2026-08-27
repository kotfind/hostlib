{
  # Hostlib: shared NixOS and home-manager modules for managing
  # hosts, users and per-host configurations.
  outputs = {...}: {
    nixosModules.default = import ./src/system.nix;

    homeManagerModules.default = import ./src/home.nix;

    lib = import ./src/lib.nix;
  };
}
