let
  inherit (builtins) mapAttrs;

  util = import ./util.nix;

  nixosModule = import ./os.nix;
  homeModule = import ./home.nix;

  # NixOS modules for one host: the caller's system modules, the
  # hostlib modules, the profile, and home-manager wiring for all of
  # the host's users.
  mkHostModules = {
    profiles,
    systemModules,
    homeModules,
    homeManagerModule,
    hostName,
  }:
    systemModules
    ++ [
      nixosModule
      homeManagerModule
      profiles
      {hostlib.curHostName = hostName;}
      {
        home-manager.users = util.genAttrs (profiles.hostlib.hosts.${hostName}.userNames) (userName: {
          imports = [profiles homeModule] ++ homeModules;
          hostlib = {
            curHostName = hostName;
            curUserName = userName;
          };
        });
      }
    ];
in {
  inherit mkHostModules;

  # One nixosConfiguration per host in the profile.
  eachHostSystem = {nixosSystem, ...} @ args:
    mapAttrs (hostName: _:
      nixosSystem {
        system = "x86_64-linux";
        modules = mkHostModules {
          inherit (args) homeManagerModule homeModules profiles systemModules;
          inherit hostName;
        };
      })
    args.profiles.hostlib.hosts;
}
