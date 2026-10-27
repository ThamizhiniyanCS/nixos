{
  imports = [
    ./home.nix
    ./dotfiles
    ../common
    ../features/cli
    ../features/desktop
  ];

  features = {
    cli = {
      fish.enable = true;
      fzf.enable = true;
      fastfetch.enable = true;
    };

    desktop = {
      wayland.enable = true;
      fonts.enable = true;
    };
  };
}
