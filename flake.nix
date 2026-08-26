{
  # Hostlib: shared NixOS and home-manager modules for managing
  # hosts, users and per-host configurations.
  outputs = {...}: {
    nixosModules.default = import ./modules/os.nix;

    homeManagerModules.default = import ./modules/home.nix;

    lib = import ./modules/lib.nix;
  };
}
