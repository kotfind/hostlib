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
      default = cfg.users.${cfg._currentUserName} or (throw "hostlib._currentUserName must be one of the hostlib.users keys");
    };
  };

  config.hostlib.trueFor = x:
    if x._type == "host"
        then x.name == cfg._currentHost.name
    else if x._type == "user"
        then x.name == cfg._currentUser.name
    else if x._type == "userOnHost"
        then x.user.name == cfg._currentUser.name && x.host.name == cfg._currentHost.name
    else throw "hostlib.trueFor: unsupported value type '${x._type}'";

  config.assertions = [
    {
      assertion = elem cfg._currentUserName (attrNames cfg.users);
      message = "hostlib._currentUserName must be one of the hostlib.users keys";
    }
  ];
}
