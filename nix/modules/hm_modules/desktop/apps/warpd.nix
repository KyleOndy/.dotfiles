{ lib, pkgs, config, ... }:
with lib;
let cfg = config.hmFoundry.desktop.apps.warpd;
in
{
  options.hmFoundry.desktop.apps.warpd = {
    enable = mkEnableOption "warpd";
  };

  config = mkIf cfg.enable {
    #home.packages = with pkgs; [
    #  warpd
    #];

    systemd.user.services.warpd = {
      Unit = {
        descrption = "warpd";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      #path = with pkgs; [
      #  warpd
      #];
      Service = {
        ExecStart = "${pkgs.warpd}/bin/warped -f";
      };
    };
  };
}
