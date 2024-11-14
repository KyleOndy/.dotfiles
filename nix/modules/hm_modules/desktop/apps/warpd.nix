{ lib, pkgs, config, ... }:
with lib;
let cfg = config.hmFoundry.desktop.apps.warpd;
in
{
  options.hmFoundry.desktop.apps.warpd = {
    enable = mkEnableOption "warpd";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      warpd
    ];

    systemd.user.services.warpd = {
      enable = true;
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      path = with pkgs; [
        warpd
      ];
      script = "warpd -f";
    };
  };
}
