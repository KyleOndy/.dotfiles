{ pkgs, ... }:

{
  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = {
        workspaceAutoBackAndForth = true;
      };
    };
  };
}

