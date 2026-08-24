{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: let
    inherit (nixpkgs.lib) nixosSystem;
    homeManager = home-manager.nixosModules.home-manager;
  in {
    nixosConfigurations.vm = nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./os.nix

        homeManager
        (
          {...}: {
            home-manager.users.test = {
              imports = [./home.nix];
            };

            users.users.test = {
              initialPassword = "test";
              isNormalUser = true;
            };
          }
        )
      ];
    };
  };
}
