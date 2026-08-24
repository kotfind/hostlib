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
  }: {
    nixosConfigurations = hostlib.lib.eachHostSystem {
      nixosSystem = nixpkgs.lib.nixosSystem;

      homeManagerModule = home-manager.nixosModules.home-manager;

      profiles = import ./profiles.nix;

      systemModules = [
        ./os.nix
      ];

      homeModules = [
        ./home.nix
      ];
    };
  };
}
