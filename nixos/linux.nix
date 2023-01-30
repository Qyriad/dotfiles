# vim: shiftwidth=2 expandtab
{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
  };

  # Yes mount /tmp as a tmpfs.
  boot.tmpOnTmpfs = true;

  # Update timezone based on our location.
  services.localtimed.enable = true;
  services.geoclue2.enable = true;

  networking.networkmanager.enable = true;

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS for printing.
  services.printing.enable = true;

  # Our normal user.
  users.users.qyriad = {
    isNormalUser = true;
    description = "Qyriad";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = ''
        lua vim.opt.runtimepath:prepend("/home/qyriad/.config/nvim")
        source $HOME/.config/nvim/init.vim
      '';
    };
    package = pkgs.neovim-nightly;
  };

  # Other packages we want available on Linux systems.
  environment.systemPackages = with pkgs; [
    usbutils
  ];
}
