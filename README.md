# HostLib

Shared NixOS and home-manager modules for managing hosts, users and per-host configurations.

Define your hosts and users once, then use `trueFor` and `mkFor` to conditionally apply system and home-manager configuration per host, per user, or per user-on-host.

## Usage

1. Add hostlib to your inputs:

    ```nix
    inputs.hostlib.url = "github:kotfind/hostlib";
    ```

2. Define hosts and users in **profiles.nix**:

    ```nix
    {
      hostlib = {
        hosts = {
          vm1 = {
            userNames = ["root" "test"];
          };
        };

        users = {
          root = {};
          test = {};
        };
      };
    }
    ```

3. Put your NixOS configuration in **system.nix** and your home-manager configuration in **home.nix**. You can use `mkFor` and `trueFor` there:

    ```nix
    # NixOS
    {config, ...}: let
      inherit (config.hostlib) hosts mkFor;
    in {
      environment.etc."on-vm1" = mkFor hosts.vm1 {text = "on";};
    }
    ```

    ```nix
    # home-manager
    {
      config,
      pkgs,
      ...
    }: let
      inherit (config.hostlib) mkFor trueFor users;
    in {
      home.packages = mkFor users.test [pkgs.hello];

      programs.yazi.enable = trueFor users.test;
    }
    ```

4. Wire it up with `eachHostSystem` in **flake.nix**:

    ```nix
    outputs = {
      nixpkgs,
      home-manager,
      hostlib,
      ...
    }: {
      nixosConfigurations = hostlib.lib.eachHostSystem {
        nixosSystem = nixpkgs.lib.nixosSystem;

        homeManagerModule = home-manager.nixosModules.home-manager;

        profiles = import ./profiles.nix;

        systemModules = [./system.nix];

        homeModules = [./home.nix];
      };
    };
    ```

This creates one `nixosConfigurations.<host>` per host with home-manager for each of the host's users.

## Tests

The `test/` directory contains a full example: two hosts (`vm1`, `vm2`) with home-manager, plus a VM test that boots both hosts and verifies the conditional configuration.

```sh
nix flake check ./test                            # evaluate everything
nix build ./test#checks.x86_64-linux.hosts -L     # run the VM test
```
