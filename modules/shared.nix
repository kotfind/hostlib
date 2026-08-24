{
  config,
  lib,
  ...
}: let
  inherit (lib) attrNames elem mkIf mkOption types;

  cfg = config.hostlib;

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

    _currentHost = mkOption {
      type = types.attrs;
      readOnly = true;
      default = cfg.hosts.${cfg._currentHostName};
    };

    # Implemented by the `os` and `home` modules.
    trueFor = mkOption {
      type = types.functionTo types.bool;
    };

    mkFor = mkOption {
      type = types.raw;
      readOnly = true;
      default = host: mkIf (cfg.trueFor host);
    };
  };

  config.assertions = [
    {
      assertion = cfg.hosts != {};
      message = "hostlib.hosts must be defined";
    }
    {
      assertion = cfg.users != {};
      message = "hostlib.users must be defined";
    }
    {
      assertion = elem cfg._currentHostName (attrNames cfg.hosts);
      message = "hostlib._currentHostName must be one of the hostlib.hosts keys";
    }
  ];
}
