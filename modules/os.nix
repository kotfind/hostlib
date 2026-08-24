{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  customConfig = types.submodule {
    freeformType = types.lazyAttrsOf types.raw;
  };
in {
  options.hostlib = {
    hosts = mkOption {
      type = types.attrsOf customConfig;
    };

    users = mkOption {
      type = types.attrsOf customConfig;
    };
  };

  config.assertions = [
    {
      assertion = config.hostlib.hosts != {};
      message = "hostlib.hosts must be defined";
    }
    {
      assertion = config.hostlib.users != {};
      message = "hostlib.users must be defined";
    }
  ];
}
