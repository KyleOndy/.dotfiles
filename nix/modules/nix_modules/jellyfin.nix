{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.systemFoundry.jellyfin;
  stateDir = "/var/lib/jellyfin"; # todo: hardcoded
in
{
  options.systemFoundry.jellyfin = {
    enable = mkEnableOption ''
      Batteries included wrapper for jellyfin
    '';

    group = mkOption {
      type = types.str;
      # todo: can I pull the default from the jellyfin package?
      default = "jellyfin";
      description = "Group to run jellyfin under";
    };

    domainName = mkOption {
      type = types.str;
      description = "Domain to server jellyfin under";
    };

    user = mkOption {
      type = types.str;
      # todo: can I pull the default from the jellyfin package?
      default = "jellyfin";
      description = "User to server jellyfin under";
    };
    backup = mkOption {
      default = { };
      description = "Move the backups somewhere";
      type = types.submodule {
        options.enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable backup moving";
        };
        options.destinationPath = mkOption {
          type = types.path;
          default = "/var/backups/jellyfin";
          description = "Specifies the directory backups will be moved too.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      # jellyfin service
      jellyfin = {
        enable = true;
        user = cfg.user;
        group = cfg.group;
        openFirewall = true;
      };
    };

    systemFoundry.nginxReverseProxy."${cfg.domainName}" = {
      enable = true;
      proxyPass = "http://127.0.0.1:8096";
    };

    # jellyfin provides no native backup, so zip, compress it, and copy it over
    systemd.services.jellyfin-backup = mkIf cfg.backup.enable {
      startAt = "*-*-* 3:00:00";
      path = with pkgs;[
        coreutils
        gnutar
        pigz
      ];
      script = ''
        mkdir -p ${cfg.backup.destinationPath}
        tar --use-compress-program="pigz -k --best" -cvf ${cfg.backup.destinationPath}/jellyfin-$(date +%Y-%m-%d).tar.gz ${stateDir}

      '';
    };
  };
}
