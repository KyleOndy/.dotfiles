# This is a catchall for configuration items that are common across all
# machines and at this time do not make sense to break out into their own file.
{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    # these are the bare minimum needed to bootstrap into my system
    curl # get whatever random files / pgp keys I need
    gitAndTools.git # to clone the dotfiles repo
    gnumake # to apply dotfiles
    rsync # to sync from other machines
    neovim # to edit files with
  ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    #consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    # apply the X keymap to the console keymap, which affects virtual consoles
    # such as tty.
    consoleUseXkbConfig = true;
  };

  environment.pathsToLink = [ "/libexec" "/share/zsh" ];
  services.xserver = {
    enable = true;
    xkbOptions = "ctrl:nocaps"; # make caps lock a control key
    desktopManager = {
      default = "none";
      xterm.enable = false;
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [ dmenu i3status i3lock i3blocks ];
    };
  };
  # yubikey
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  environment.shellInit = ''
    export GPG_TTY="$(tty)"
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    mosh.enable = true;
  };
  # todo: will this work, or do I need to pass in explicit git hash?
  environment.etc."nixos/active".text = config.system.nixos.label;
  environment.sessionVariables = {
    # need to set this at the system level since i3 is started before I can login as a user and environment variables I set are within child processes.
    TERMINAL = "st";
  };
  # Enable the OpenSSH daemon.
  services.openssh = { enable = true; };
  # Enable sound.
  sound = {
    enable = true;
    mediaKeys = { enable = true; };
  };
  hardware.pulseaudio.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
