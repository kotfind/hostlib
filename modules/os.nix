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

  # Whether the given host is the current one.
  config.hostlib.trueFor = host: host.name == cfg._curHost.name;

  # Ensure every user of the current host exists in the system.
  config.users.users = genAttrs cfg._curHost.userNames (_: {});
}
