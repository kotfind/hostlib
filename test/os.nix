{
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
}
