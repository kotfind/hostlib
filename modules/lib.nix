let
  inherit (builtins) mapAttrs;

  nixosModule = import ./os.nix;
  homeModule = import ./home.nix;
in {
  eachHostSystem = {
    nixosSystem,
    profiles,
    systemModules,
    homeModules,
    homeManagerModule,
  }:
    mapAttrs (hostName: _:
      nixosSystem {
        system = "x86_64-linux";
        modules =
          systemModules
          ++ [
            nixosModule
            homeManagerModule
            profiles
            {hostlib.curHostName = hostName;}
            {
              home-manager.users =
                mapAttrs (userName: _: {
                  imports = [profiles homeModule] ++ homeModules;
                  hostlib = {
                    curHostName = hostName;
                    curUserName = userName;
                  };
                })
                profiles.hostlib.users;
            }
          ];
      })
    profiles.hostlib.hosts;
}
