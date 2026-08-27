let
  inherit (builtins) listToAttrs map;
in {
  # Build an attrset from a list of names: `genAttrs names f` is
  # `{name = f name;}` for every name in `names`.
  genAttrs = names: f:
    listToAttrs (map (name: {
        inherit name;
        value = f name;
      })
      names);
}
