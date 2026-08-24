{
  config,
  lib,
  ...
}: let
  inherit (lib) attrNames elem mkOption types;

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

    _currentHostName = mkOption {
      type = types.str;
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
    {
      assertion = elem config.hostlib._currentHostName (attrNames config.hostlib.hosts);
      message = "hostlib._currentHostName must be one of the hostlib.hosts keys";
    }
  ];
}
