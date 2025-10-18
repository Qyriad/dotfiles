{
	disko.devices = {

		disk.yuki-a = {
			#device = "/dev/nvme0n1";
			device = "/dev/disk/by-path/pci-0000:08:00.0-nvme-1";
			#device = "/dev/disk/by-id/nvme-eui.0025384551a42c97"
			#device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7HENU2Y504819W";
			type = "disk";

			content = {
				type = "gpt";

				partitions.ESP = {
					# ef00 EFI system partition.
					type = "EF00";
					size = "2G";
					content = {
						type = "filesystem";
						format = "vfat";
						mountpoint = "/boot/efi";

						# For mkfs.vfat
						extraArgs = [ "-n" "yuki-esp" ];
					};
				};

				partitions.mdadm = {
					size = "100%";
					# fd00 Linux RAID.
					type = "fd00";
					content = {
						type = "mdraid";
						name = "yuki-r0";
					};
				};

			};
		};

		disk.yuki-b = {
			#device = "/dev/nvme3n1";
			device = "/dev/disk/by-path/pci-0000:24:00.0-nvme-1";
			#device = "/dev/disk/by-id/nvme-eui.0025384551a42c98";
			#device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7HENU2Y504820D";
			type = "disk";

			content = {
				type = "gpt";

				partitions.ESP = {
					# ef00 EFI system partition.
					type = "EF00";
					size = "2G";
					content = {
						type = "filesystem";
						format = "vfat";
						#mountpoint = "/boot/efi";

						# For mkfs.vfat
						extraArgs = [ "-n" "yuki-esp" ];
					};
				};

				partitions.mdadm = {
					size = "100%";
					# fd00 Linux RAID.
					type = "fd00";
					content = {
						type = "mdraid";
						name = "yuki-r0";
					};
				};

			};
		};

		mdadm.yuki-r0 = {
			type = "mdadm";
			level = 0;
			# Work with EFI!.
			metadata = "1.0";

			content = {
				type = "gpt";

				partitions.root = {
					# 8304 Linux x86-64 root
					type = "8304";
					start = "2G";
					end = "-32G";
					#size = "100%";
					priority = 200;
					content = {
						type = "filesystem";
						format = "ext4";
						mountpoint = "/";

						mountOptions = [
							"defaults"
							"discard"
						];

						# For mkfs.ext4
						extraArgs = [ "-L" "yuki-root" ];
					};
				};

				partitions.swap = {
					# 8200 Linux swap.
					type = "8200";
					#size = "32G";
					#start = "-32G";
					size = "100%";
					content = {
						type = "swap";
						discardPolicy = "both";
						resumeDevice = true;

						# For mkswap.
						extraArgs = [ "-L" "yuki-swap" ];
					};
				};
			};
		};

	};
}
