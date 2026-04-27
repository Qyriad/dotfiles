{
	linkFarm,
}: linkFarm "qyriad-systemd-extra" {
	"etc/systemd/system" = linkFarm "qyriad-systemd-extra-systemd-system" {
		"ffcap-elgato-wanted.target" = ./ffcap-elgato-wanted.target;
		"ffcap-elgato-up.target" = ./ffcap-elgato-up.target;
	};
}
