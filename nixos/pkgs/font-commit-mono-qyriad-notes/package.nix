{
	lib,
	runCommandMinimal,
	fd,
}: runCommandMinimal "font-commit-mono-qyriad-notes" {
	src = lib.fileset.toSource {
		root = ./.;
		fileset = lib.fileset.unions [
			./CommitMonoQyriadNotes-400-Regular.otf
			./CommitMonoQyriadNotes-400-Italic.otf
			./CommitMonoQyriadNotes-700-Regular.otf
			./CommitMonoQyriadNotes-700-Italic.otf
		];
	};

	nativeBuildInputs = [ fd ];

} <| lib.dedent ''
	fd '\.otf$' "$src" -x \
		install -D --mode=a=r --target-directory="$out/share/fonts/opentype/commit-mono-qyriad-notes"
''
