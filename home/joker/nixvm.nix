{ config, ... }: {
  imports = [
    ./home.nix
    ../common
    ../features/cli
  ];

  features = {
    cli = {
      fish.enable = true;
    };
  };
}
