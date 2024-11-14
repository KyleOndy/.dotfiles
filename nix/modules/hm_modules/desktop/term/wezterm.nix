{ lib, pkgs, config, ... }:
with lib;
let cfg = config.hmFoundry.desktop.term.wezterm;
in
{
  options.hmFoundry.desktop.term.wezterm = {
    enable = mkEnableOption "wezterm";
    descrption = "
    WezTerm is a powerful cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust

    https://wezfurlong.org/wezterm/index.html
    ";
  };

  config = mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        front_end=‘WebGpu’
      '';
    };
  };
}
