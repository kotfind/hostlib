{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hostlib.url = "path:..";
  };

  outputs = {
    nixpkgs,
    home-manager,
    hostlib,
    ...
  }: let
    inherit (nixpkgs.lib) nixosSystem;
    homeManager = home-manager.nixosModules.home-manager;
  in {
    nixosConfigurations.vm = nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./os.nix

        hostlib.nixosModules.default

        ./profiles.nix

        homeManager
        (
          {...}: {
            hostlib.curHostName = "vm1";

            home-manager.users.test = {
              imports = [./home.nix ./profiles.nix hostlib.homeManagerModules.default];

              hostlib.curHostName = "vm1";
              hostlib.curUserName = "test";
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
