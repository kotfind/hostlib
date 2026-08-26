let
  inherit (builtins) mapAttrs;

  util = import ./util.nix;

  nixosModule = import ./os.nix;
  homeModule = import ./home.nix;
in {
  eachHostSystem = {
    nixosSystem,
    profiles,
    systemModules,
    homeModules,
    homeManagerModule,
  }: let
    inherit (profiles.hostlib) hosts;
    inherit (util) genAttrs;
  in
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
              home-manager.users = genAttrs (hosts.${hostName}.userNames) (userName: {
                imports = [profiles homeModule] ++ homeModules;
                hostlib = {
                  curHostName = hostName;
                  curUserName = userName;
                };
              });
            }
          ];
      })
    hosts;
}
