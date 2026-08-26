let
  inherit (builtins) listToAttrs map;
in {
  genAttrs = names: f:
    listToAttrs (map (name: {
        inherit name;
        value = f name;
      })
      names);
}
