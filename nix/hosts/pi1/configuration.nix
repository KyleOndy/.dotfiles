{ config, pkgs, lib, ... }:

{
  networking = {
    hostName = "pi1";
    interfaces.eth0.useDHCP = true;
  };

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  powerManagement.cpuFreqGovernor = "ondemand";
  system.stateVersion = "20.09";


  systemFoundry = {
    dnsServer = {
      enable = true;
      blacklist.enable = false;

      upstreamDnsServers = [ "10.24.89.1" ];
      aRecords = {
        #"util.lan.509ely.com" = "10.24.89.53"; # why?

        # monitoring
        #"prometheus.apps.lan.509ely.com" = "10.24.89.5";
        #"grafana.apps.lan.509ely.com" = "10.24.89.5";

        #"local.509ely.com" = "127.0.0.1";
      };
      cnameRecords = { };
      domainRecords = {
        "dmz.509ely.com" = "10.25.89.5";
        "apps.dmz.509ely.com" = "10.25.89.5";
      };
    };
  };
  # TODO: add systemd service to check is we can resolve DNS from self, if not,
  #       restart dnsmasq. That fact that we hardcode the IP address is
  #       fragile, but it works for now. I really do need to figure out _why_
  #       this happens and fix the root issue.
  systemd.services.dnsmasq-watchdog = {
    enable = true;
    startAt = "*-*-* *:*:00/20"; # every twenty seconds.
    path = with pkgs; [
      dnsutils
    ];
    script = ''
      set -x
      [[ -z $(dig @10.24.89.53 pi1.lan.509ely.com +short) ]] && systemctl restart dnsmasq || exit 0
    '';
  };
}
