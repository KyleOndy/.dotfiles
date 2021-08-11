{ lib, pkgs, config, ... }:
with lib;
let cfg = config.foundry.terminal.pass;
in
{
  options.foundry.terminal.pass = {
    enable = mkEnableOption "Pass; the standard unix passowrd manager";
  };

  config = mkIf cfg.enable {
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (ext: [ ext.pass-otp ]);
    };

    home.packages = with pkgs; [
      passff-host # firefox plugin host extension
    ];
  };
}
