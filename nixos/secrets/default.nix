let
	mkSecret = publicKeys: { armor = true; inherit publicKeys; };

	#yk5c = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDI6Tdxcbr3XSD2Ok2tUb4RJ3nOszqKklkqXUrgnFM1F cardno:26_907_287";
	#yuki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILJUNbKoVL//oDRRn9/Gizj93GJ7TGL/t1lQbnGo8ibD";
	yk5c = "age1yubikey1qtq5juddcf5stccawfh706xdc09jds729f96t85q0fm29at0a5ezulfmxh9";
	yuki.qyriad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGuURQDdkB0wJGCCZra7TD7SRB+AJw3jlimZ40qq8OLE qyriad@Yuki";
	yuki.host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHVyAHBPz+v/m6s+lB4wy4ViPGXwrk1Cdfy0Bo9uaNW root@Yuki";
in {
	"shizue-cred.age" = mkSecret [
		yk5c
		#yuki.qyriad
		yuki.host
	];
}
