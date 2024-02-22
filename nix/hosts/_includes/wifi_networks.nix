# wifi network configurations. Just include all configurations on all machines
# with wifi for now.
#
# todo: make psk's actually secret. pull from pass?
{ config, pkgs, ... }:

{
  # Enables wireless support via wpa_supplicant.
  networking.wireless = {
    enable = false;
    networks = {
      "The Ondy's" = {
        pskRaw =
          "a2db56e5a0efe7c2e8eaca97d4bc4d872234dda49862554e02ce74696d8306e3";
      };
      "Kyle's iPhone" = {
        pskRaw =
          "1fea8faabb7dc8c28812fa1c9a4251ba0745065490139bcbb0fb7a5a4514a99a";
      };
      # note: how to connect to unproteced wifi, works with captive portal
      #"GuestNet" = { };
    };
  };
}
