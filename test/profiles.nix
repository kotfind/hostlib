{
  hostlib = {
    hosts = {
      vm1 = {
        userNames = [
          "root"
          "test"
        ];
      };

      vm2 = {
        userNames = [
          "root"
        ];
      };
    };

    users = {
      root = {};
      test = {};
    };
  };
}
