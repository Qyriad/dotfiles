# vim: shiftwidth=4 tabstop=4 noexpandtab
{ config, pkgs, ... }:

let
	udevRulesPkg = pkgs.callPackage ./udev-rules { };
in
{
	# Bootloader.
	boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
		efi.efiSysMountPoint = "/boot/efi";
	};

	# Yes mount /tmp as a tmpfs.
	boot.tmp.useTmpfs = true;

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

	services.openssh.enable = true;

	# Our normal user.
	users.users.qyriad = {
		isNormalUser = true;
		description = "Qyriad";
		extraGroups = [ "wheel" "networkmanager" "plugdev" "dialout" ];
		shell = pkgs.zsh;
	};

	nix.settings.trusted-users = [
		"root"
		"qyriad"
	];

	programs.zsh.enable = true;

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
	};

	services.udev.packages = [
		udevRulesPkg
	];

	# Other packages we want available on Linux systems.
	environment.systemPackages = with pkgs; [
		usbutils
		pciutils
		(gdb.override { enableDebuginfod = true; })
		qt5.qtbase
	];
	services.nixseparatedebuginfod.enable = true;
}
