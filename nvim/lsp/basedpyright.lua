local qyriad = require('qyriad')

local SEVERITY = {
	ERROR = 'error',
	WARN = 'warning',
	INFO = 'information',
	OFF = 'none',
}

return qyriad.nested_tbl {
	filetypes = { 'python' },
	cmd = { 'basedpyright', '--stdio', '--verbose' },
	['settings.basedpyright'] = {
		['analysis.inlayHints.genericTypes'] = true,
		['analysis.diagnosticSeverityOverrides'] = {
			--reportAny = 'hint',
			reportAny = SEVERITY.INFO,
			reportUnusedCallResult = SEVERITY.OFF,
			reportMissingParameterType = SEVERITY.INFO,
			reportUnknownParameterType = SEVERITY.INFO,
			reportUnknownVariableType = SEVERITY.INFO,
			reportUnknownMemberType = SEVERITY.INFO,
			reportUnknownArgumentType = SEVERITY.INFO,
			reportWildcardImportFromLibrary = SEVERITY.INFO,
		},
	},
}
