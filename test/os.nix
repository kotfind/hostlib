{
  config,
  lib,
  ...
}: let
  inherit (config.hostlib) hosts mkFor trueFor;
in {
  boot.loader.grub.device = "/dev/vda";

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  networking.hostName = "vm";

  system.stateVersion = "26.11";

  users.users.test = {
    initialPassword = "test";
    isNormalUser = true;
  };

  # system: mkFor HOST
  environment.etc."hostlib-mkfor-host" = mkFor hosts.vm1 {text = "on";};

  environment.etc."hostlib-mkfor-vm2" = mkFor hosts.vm2 {text = "on";};

  # system: trueFor HOST
  environment.etc."hostlib-truefor-host" = lib.mkIf (trueFor hosts.vm1) {text = "on";};
}
