{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  virtualisation.qemu.networkingOptions = lib.mkForce [
    "-device e1000,netdev=net0"
    "-netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
  ];

  networking.firewall.allowedTCPPorts = [
    22
  ];

}
