{
  config,
  pkgs,
  inputs,
  ...
}:
{
  users.users.joker = {
    # $ mkpasswd <password>
    initialHashedPassword = "$y$j9T$rEzl9FA.PcXRZawGPbaUB/$MNjJlwLpHO2VX2NZQkTw6u7QIjKBDMFmq5oFzEQ9toD";
    isNormalUser = true;
    description = "joker";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLXuLWSOdmel6MJaERCcvbg8EbNYUjRJBhyLmZB4kh2 my-nix ssh"
    ];
    packages = [ inputs.home-manager.packages.${pkgs.system}.default ];
  };

  home-manager.users.joker = import ../../../home/joker/${config.networking.hostName}.nix;
}
