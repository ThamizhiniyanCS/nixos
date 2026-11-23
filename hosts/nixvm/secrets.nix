{
  age = {
    secrets = {
      secret = {
        file = ../../secrets/secret.age;
      };
      joker-secret = {
        file = ../../secrets/joker-secret.age;
        owner = "joker";
      };
    };

  };
}
