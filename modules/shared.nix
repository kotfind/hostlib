{
  config,
  lib,
  ...
}: let
  inherit (builtins) attrValues concatMap map;
  inherit (lib) attrNames elem mkIf mkOption types;

  cfg = config.hostlib;

  customConfig = types.submodule ({
    config,
    name,
    ...
  }: {
    freeformType = types.lazyAttrsOf types.raw;

    options.name = mkOption {
      type = types.str;
      readOnly = true;
      default = name;
    };

    options._type = mkOption {
      type = types.str;
      readOnly = true;
      default = "host";
    };

    options.userNames = mkOption {
      type = types.listOf types.str;
    };

    options.users = mkOption {
      type = types.listOf types.attrs;
      readOnly = true;
      default = map (userName: cfg.users.${userName}) config.userNames;
    };
  });
in {
  options.hostlib = {
    hosts = mkOption {
      type = types.attrsOf customConfig;
    };

    users = mkOption {
      type = types.attrsOf (types.submodule ({
        config,
        name,
        ...
      }: {
        freeformType = types.lazyAttrsOf types.raw;

        options.name = mkOption {
          type = types.str;
          readOnly = true;
          default = name;
        };

        options._type = mkOption {
          type = types.str;
          readOnly = true;
          default = "user";
        };

        options.at = mkOption {
          type = types.functionTo types.attrs;
          default = host: {
            _type = "userOnHost";
            user = config;
            host = host;
          };
        };
      }));
    };

    curHostName = mkOption {
      type = types.str;
    };

    _curHost = mkOption {
      type = types.attrs;
      readOnly = true;
      default = cfg.hosts.${cfg.curHostName} or (throw "hostlib.curHostName must be one of the hostlib.hosts keys");
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

  config.assertions =
    [
      {
        assertion = cfg.hosts != {};
        message = "hostlib.hosts must be defined";
      }
      {
        assertion = cfg.users != {};
        message = "hostlib.users must be defined";
      }
      {
        assertion = elem cfg.curHostName (attrNames cfg.hosts);
        message = "hostlib.curHostName must be one of the hostlib.hosts keys";
      }
    ]
    ++ concatMap (
      host:
        map (userName: {
          assertion = elem userName (attrNames cfg.users);
          message = "hostlib.hosts.${host.name}: '${userName}' must be one of the hostlib.users keys";
        })
        host.userNames
    ) (attrValues cfg.hosts);
}
