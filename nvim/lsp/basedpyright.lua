local qyriad = require('qyriad')

local SEVERITY = {
	ERROR = 'error',
	WARN = 'warning',
	INFO = 'information',
	OFF = 'none',
}

return qyriad.nested_tbl {
	filetypes = { 'python' },
	cmd = { 'basedpyright-langserver', '--stdio', '--verbose' },
	['settings.basedpyright.analysis'] = {
		deprecateTypingAliases = false,
		typeCheckingMode = 'basic',
		['inlayHints.genericTypes'] = true,
		['diagnosticSeverityOverrides'] = {
			reportAny = SEVERITY.INFO,
			reportDeprecated = SEVERITY.INFO,
			reportExplicitAny = SEVERITY.OFF,
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
