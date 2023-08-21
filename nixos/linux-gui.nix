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

  # Use a Wayland KDE Plasma desktop environment, with systemd integration.
  services.xserver = {

    displayManager = {
      sddm.enable = true;
      defaultSession = "plasmawayland";
    };

    desktopManager = {
      plasma5.enable = true;
      plasma5.runUsingSystemd = true;
    };
  };

  # And also let Blink stuffs use Wayland.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
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

  programs.gnupg.agent.pinentryFlavor = "qt";

  # Enable udisks2.
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    mpv
    wl-clipboard
    ksshaskpass
    opera
    firefox
    obsidian
    discord
    calibre
  ];

  # Setup the terminal font we use.
  fonts.fonts = [
    nerdFonts
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "InconsolataGo Nerd Font Mono"
  ];


  # Enable reasonable default fonts for unicode and emoji.
  fonts.enableDefaultFonts = true;
}
