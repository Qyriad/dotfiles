to_entries
| map(
	del(
		..
		| select(. == null or . == "" or . == {} or . == [])
	)
	| .value + { drvPath: .key }
	#.value + {
	#	drvPath: .key,
	#	env: .value.env
	#		| map_values(select(. != "")),
	#	# Remove empty attributes in each `inputDrvs`
	#	inputDrvs: .value.inputDrvs
	#		| map_values(
	#			map_values(select(. != {}))
	#		),
	#}
)
| if length == 1 then .[0] else . end
