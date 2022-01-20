# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
{ config, pkgs, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # configure proprietary drivers
  nixpkgs.config.allowUnfree = true;
  boot.initrd.kernelModules = [ "wl" ];
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # programs that should be available in the installer
  environment.systemPackages = with pkgs; [
    bat
    git
    neovim
    rsync
  ];

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  # todo: pull this dynamically?
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII06ucMODALjreR0beoVmxbAikW72cZBpfBXG/ZU9nbH kyle@alpha"
  ];
}
