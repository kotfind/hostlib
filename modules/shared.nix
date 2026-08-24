{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  customConfig = types.submodule ({name, ...}: {
    freeformType = types.lazyAttrsOf types.raw;

    options.name = mkOption {
      type = types.str;
      readOnly = true;
      default = name;
    };
  });
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
