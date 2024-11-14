{ lib, pkgs, config, ... }:
with lib;
let cfg = config.hmFoundry.desktop.apps.warpd;
in
{
  options.hmFoundry.desktop.apps.warpd = {
    enable = mkEnableOption "warpd";
  };

  config = mkIf cfg.enable {
    systemd.user.services.warpd = {
      Unit = {
        descrption = "warpd";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.warpd}/bin/warped -f";
      };
    };
  };
}
