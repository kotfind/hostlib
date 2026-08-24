{
  config,
  lib,
  ...
}: let
  inherit (lib) attrNames elem mkOption types;

  cfg = config.hostlib;
in {
  imports = [
    ./shared.nix
  ];

  options.hostlib = {
    _currentUserName = mkOption {
      type = types.str;
    };

    _currentUser = mkOption {
      type = types.attrs;
      readOnly = true;
      default = cfg.users.${cfg._currentUserName} or throw "hostlib._currentUserName must be one of the hostlib.users keys";
    };
  };

  config.hostlib.trueFor = host: host.name == cfg._currentHost.name;

  config.assertions = [
    {
      assertion = elem cfg._currentUserName (attrNames cfg.users);
      message = "hostlib._currentUserName must be one of the hostlib.users keys";
    }
  ];
}
