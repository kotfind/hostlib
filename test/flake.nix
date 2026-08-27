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
    profiles = import ./profiles.nix;
  in {
    nixosConfigurations = hostlib.lib.eachHostSystem {
      nixosSystem = nixpkgs.lib.nixosSystem;

      homeManagerModule = home-manager.nixosModules.home-manager;

      inherit profiles;

      systemModules = [
        ./system.nix
      ];

      homeModules = [
        ./home.nix
      ];
    };

    checks.x86_64-linux = import ./checks.nix {
      inherit home-manager hostlib nixpkgs profiles;
    };
  };
}
