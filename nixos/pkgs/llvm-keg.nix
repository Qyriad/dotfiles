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

	libgcc = libgcc.out;

	llvm = llvmPackages.llvm.out;

	meta.description = "llvm tools not in /bin";
} <| lib.dedent ''
	mkdir -p "$out/opt/llvm"
	lndir -silent "$clang" "$out/opt/llvm"
	lndir -silent "$lld" "$out/opt/llvm"
	lndir -silent "$llvm" "$out/opt/llvm"
	mkdir -p "$out/opt/llvm/include"
	# Bleh. libstdc++ includes.
	lndir -silent "$libgcc/include" "$out/opt/llvm/include"
''
