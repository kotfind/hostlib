{
  config,
  lib,
  ...
}: let
  inherit (lib) genAttrs;

  cfg = config.hostlib;
in {
  imports = [
    ./shared.nix
  ];

  config.hostlib.trueFor = host: host.name == cfg._curHost.name;

  config.users.users = genAttrs cfg._curHost.userNames (_: {});
}
