{
  config,
  lib,
  ...
}: let
  inherit (lib) attrNames elem mkOption types;
in {
  imports = [
    ./shared.nix
  ];

  options.hostlib._currentHostName = mkOption {
    type = types.str;
  };

  config.assertions = [
    {
      assertion = elem config.hostlib._currentHostName (attrNames config.hostlib.hosts);
      message = "hostlib._currentHostName must be one of the hostlib.hosts keys";
    }
  ];
}
