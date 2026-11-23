let
  nixvm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAkVkddYJld2glJSEXw9MlXo9Ho//lZ/6n3J0hQ9CYXW";
  joker-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLXuLWSOdmel6MJaERCcvbg8EbNYUjRJBhyLmZB4kh2";
in
{
  "secret.age".publicKeys = [
    nixvm
    joker-host
  ];
  "joker-secret.age".publicKeys = [
    nixvm
    joker-host
  ];
}
