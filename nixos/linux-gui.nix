# vim: shiftwidth=2 expandtab

{ config, pkgs, ... }:

let
  nerdFonts = pkgs.nerdfonts.override {
    fonts = [
      "InconsolataGo"
    ];
  };
in {

  # Enable GUI stuff in general.
  # Yes this says xserver. Yes this we're using Wayland. That's correct.
  services.xserver.enable = true;

  # Enable the KDE Plasma desktop environment, with systemd integration.
  services.xserver = {
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    desktopManager.plasma5.runUsingSystemd = true;
  };

  # Enable sound with Pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now).
    #media-session.enable = true;
  };

  # FIXME: Is this necessary?
  services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    opera
    wl-clipboard
    ksshaskpass
    obsidian
    discord
  ];

  # The terminal font we use.
  fonts.fonts = [
    nerdFonts
  ];

  xdg.portal.enable = true;
}
