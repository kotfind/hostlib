{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.hostlib) hosts mkFor trueFor users;
in {
  home.stateVersion = "26.11";

  # home-manager: mkFor USER
  home.packages = mkFor users.test (with pkgs; [hello]);

  # home-manager: mkFor HOST
  home.file.".hostlib-mkfor-host" = mkFor hosts.vm1 {text = "on";};

  # home-manager: mkFor USER_ON_HOST
  home.file.".hostlib-mkfor-user-on-host" = mkFor (users.test.at hosts.vm1) {text = "on";};

  # home-manager: trueFor USER
  home.file.".hostlib-truefor-user" = lib.mkIf (trueFor users.test) {text = "on";};
}
