{config, ...}: let
  cfg = config.hostlib;
in {
  imports = [
    ./shared.nix
  ];

  config.hostlib.trueFor = host: host.name == cfg._curHost.name;
}
