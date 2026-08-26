{
  home-manager,
  hostlib,
  nixpkgs,
  profiles,
}: let
  inherit (nixpkgs.legacyPackages.x86_64-linux.testers) runNixOSTest;

  mkHost = hostName: {
    imports = hostlib.lib.mkHostModules {
      inherit profiles;

      systemModules = [
        ./os.nix
      ];

      homeModules = [
        ./home.nix
      ];

      homeManagerModule = home-manager.nixosModules.home-manager;

      inherit hostName;
    };
  };
in {
  hosts = runNixOSTest {
    name = "hosts";

    nodes = {
      vm1 = mkHost "vm1";
      vm2 = mkHost "vm2";
    };

    testScript = ''
      vm1.wait_for_unit("multi-user.target")
      vm2.wait_for_unit("multi-user.target")

      # home-manager: mkFor USER
      vm1.succeed("su - test -c hello")

      # home-manager: mkFor HOST
      vm1.succeed("test -f /home/test/.hostlib-mkfor-host")

      # home-manager: mkFor USER_ON_HOST
      vm1.succeed("test -f /home/test/.hostlib-mkfor-user-on-host")

      # home-manager: trueFor USER
      vm1.succeed("test -f /home/test/.hostlib-truefor-user")

      # system: mkFor HOST
      vm1.succeed("grep -q on /etc/hostlib-mkfor-host")

      # system: trueFor HOST
      vm1.succeed("grep -q on /etc/hostlib-truefor-host")

      # system: mkFor HOST (vm2 only)
      vm2.succeed("grep -q on /etc/hostlib-mkfor-vm2")

      # none of the vm1-conditional things apply on vm2
      vm2.fail("su - test -c hello")
      vm2.fail("test -f /home/test/.hostlib-mkfor-host")
      vm2.fail("test -f /home/test/.hostlib-mkfor-user-on-host")
      vm2.fail("test -f /home/test/.hostlib-truefor-user")
      vm2.fail("test -f /etc/hostlib-mkfor-host")
      vm2.fail("test -f /etc/hostlib-truefor-host")

      # nothing vm2-conditional applies on vm1
      vm1.fail("test -f /etc/hostlib-mkfor-vm2")
    '';
  };
}
