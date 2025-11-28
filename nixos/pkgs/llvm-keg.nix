{
	lib,
	llvmPackages,
	wrapBintoolsWith,
	runCommandMinimal,
	lndir,
}: runCommandMinimal "llvm-keg" {

	nativeBuildInputs = [
		lndir
	];

	clang = llvmPackages.stdenv.cc;
	lld = wrapBintoolsWith {
		bintools = llvmPackages.bintools;
	};

	meta.description = "llvm tools not in /bin";
} <| lib.dedent ''
	mkdir -p "$out/opt/llvm"
	lndir -silent "$clang" "$out/opt/llvm"
	lndir -silent "$lld" "$out/opt/llvm"
''
