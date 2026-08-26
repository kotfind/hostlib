{
  config,
  lib,
  ...
}: let
  inherit (builtins) attrValues concatMap map;
  inherit (lib) attrNames elem mkIf mkOption types;

  cfg = config.hostlib;

  # Type of a host entry: freeform custom values plus the built-in
  # `name`, `_type`, `userNames` and `users` options.
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
      description = "Name of the host.";
      example = "vm1";
    };

    options._type = mkOption {
      type = types.str;
      readOnly = true;
      default = "host";
      description = "Marks this value as a host.";
      example = "host";
    };

    options.userNames = mkOption {
      type = types.listOf types.str;
      description = "Users that exist on this host. Each name must be a key of `hostlib.users`.";
      example = ["root" "test"];
    };

    options.users = mkOption {
      type = types.listOf types.attrs;
      readOnly = true;
      default = map (userName: cfg.users.${userName}) config.userNames;
      description = "User configs of this host, resolved from `userNames`.";
      example = [{name = "root";}];
    };
  });
in {
  options.hostlib = {
    hosts = mkOption {
      type = types.attrsOf customConfig;
      description = "All known hosts, keyed by host name.";
      example = {vm1 = {userNames = ["root" "test"];};};
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
          description = "Name of the user.";
          example = "admin";
        };

        options._type = mkOption {
          type = types.str;
          readOnly = true;
          default = "user";
          description = "Marks this value as a user.";
          example = "user";
        };

        options.at = mkOption {
          type = types.functionTo types.attrs;
          default = host: {
            _type = "userOnHost";
            user = config;
            host = host;
          };
          description = "Combine this user with a host into a `userOnHost` value.";
          example = "users.test.at hosts.vm1";
        };
      }));
      description = "All known users, keyed by user name.";
      example = {admin = {shell = "zsh";};};
    };

    curHostName = mkOption {
      type = types.str;
      description = "Name of the current host. Must be a key of `hostlib.hosts`.";
      example = "vm1";
    };

    _curHost = mkOption {
      type = types.attrs;
      readOnly = true;
      default = cfg.hosts.${cfg.curHostName} or (throw "hostlib.curHostName must be one of the hostlib.hosts keys");
      description = "The host entry selected by `curHostName`.";
      example = {name = "vm1";};
    };

    # Implemented by the `os` and `home` modules.
    trueFor = mkOption {
      type = types.functionTo types.bool;
      description = "Whether a host, user or `userOnHost` value matches the current host (and current user in home-manager).";
      example = "trueFor hosts.vm1";
    };

    mkFor = mkOption {
      type = types.raw;
      readOnly = true;
      default = host: mkIf (cfg.trueFor host);
      description = "Conditionally apply config for a host, user or `userOnHost` value: `mkFor value { ... }` expands to `mkIf (trueFor value) { ... }`.";
      example = "environment.etc.\"hostlib-mkfor-host\" = mkFor hosts.vm1 {text = \"on\";};";
    };
  };

  # Validate that required options are defined and consistent.
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
