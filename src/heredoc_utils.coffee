# heredoc_utils.coffee

import {say, isTAML, taml} from '@jdeighan/coffee-utils'
import {undentedBlock} from '@jdeighan/coffee-utils/indent'

# ---------------------------------------------------------------------------

export patch = (line, lSections) ->

	for lLines in lSections
		start = line.indexOf('<<<')
		if start == -1
			throw "patch(): No HEREDOC marker found"
		result = build(lLines)
		line = line.replace('<<<', JSON.stringify(result))
	if line.indexOf('<<<') != -1
		throw "patch(): Not all HEREDOC markers were replaced"
	return line

# ---------------------------------------------------------------------------

export build = (lLines, debug) ->

	# --- if lLines is empty or of length 0:
	#        returns empty string

	if not lLines?
		if debug
			say "build(): lLines undefined - return ''"
		return ''
	if lLines.length == 0
		if debug
			say "build(): lLines len = 0 - return ''"
		return ''

	# --- This removes whatever indentation is found on
	#     the first line from ALL lines
	if debug
		say JSON.stringify(lLines)
		say "   UNDENT"

	str = undentedBlock(lLines)

	if isTAML(str)
		if debug
			say "   TAML found - converting"
		return taml(str)
	else
		return str

# ---------------------------------------------------------------------------

export numHereDocs = (str) ->

	n = 0
	pos = str.indexOf('<<<');
	while (pos != -1)
		n += 1
		pos = str.indexOf('<<<', pos+1)
	return n
