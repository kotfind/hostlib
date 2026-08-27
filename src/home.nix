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
    # Name of the user the current home-manager configuration is for.
    curUserName = mkOption {
      type = types.str;
      description = "Name of the current user. Must be a key of `hostlib.users`.";
      example = "admin";
    };

    # The user entry selected by `curUserName`.
    _curUser = mkOption {
      type = types.attrs;
      readOnly = true;
      default = cfg.users.${cfg.curUserName} or (throw "hostlib.curUserName must be one of the hostlib.users keys");
      description = "The user entry selected by `curUserName`.";
      example = {name = "admin";};
    };
  };

  # Whether the given value matches the current user and host.
  config.hostlib.trueFor = x:
    if x._type == "host"
    then x.name == cfg._curHost.name
    else if x._type == "user"
    then x.name == cfg._curUser.name
    else if x._type == "userOnHost"
    then x.user.name == cfg._curUser.name && x.host.name == cfg._curHost.name
    else throw "hostlib.trueFor: unsupported value type '${x._type}'";

  config.assertions = [
    {
      assertion = elem cfg.curUserName (attrNames cfg.users);
      message = "hostlib.curUserName must be one of the hostlib.users keys";
    }
  ];
}
