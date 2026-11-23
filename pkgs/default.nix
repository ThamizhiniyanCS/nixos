{ pkgs, ... }: {
  # Define your custom packages here
  zellij-ps = pkgs.callPackage ./zellij-ps { };
}
