{ pkgs, ... }:

{
  programs.dconf.enable = true;
  enviroemnt = {
    systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];
    #gnome.excludePackages = with gnome; [
    #  gedit
    #  # gnome-terminal
    #  gnome-software
    #  gnome-music
    #  # gnome-photos
    #  simple-scan
    #  totem
    #  epiphany
    #  geary
    #];
  };
  services = {
    xserver = {
      displayManager = {
        gdm.enable = true;
        #defaultSession = "plasmawayland";
      };
      desktopManager = {
        gnome.enable = true;
      };
    };
    gtk = {
      enable = true;

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "palenight";
        package = pkgs.palenight-theme;
      };

      cursorTheme = {
        name = "Numix-Cursor";
        package = pkgs.numix-cursor-theme;
      };

      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };

    home.sessionVariables.GTK_THEME = "palenight";
  };
}
