{ pkgs, ... }: {
  imports = [
    ./fish.nix
    ./fzf.nix
    ./fastfetch.nix
  ];

  programs = {
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      extraOptions = [
        "-l"
        "--icons"
        "--git"
        "-a"
      ];
    };

    bat = {
      enable = true;
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };

  home.packages = with pkgs; [
    coreutils
    fd
    htop
    httpie
    jq
    procs
    ripgrep
    tldr
    zip
  ];
}
