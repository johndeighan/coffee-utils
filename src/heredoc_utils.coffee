# heredoc_utils.coffee

import {
	say,
	isTAML,
	taml,
	warn,
	error,
	debug,
	} from '@jdeighan/coffee-utils'
import {undentedBlock} from '@jdeighan/coffee-utils/indent'

# ---------------------------------------------------------------------------

export numHereDocs = (str) ->

	n = 0
	pos = str.indexOf('<<<');
	while (pos != -1)
		n += 1
		pos = str.indexOf('<<<', pos+3)
	return n

# ---------------------------------------------------------------------------

export patch = (line, lSections, callBack=stdCallback) ->

	lParts = []     # joined at the end
	pos = 0
	for lLines in lSections
		start = line.indexOf('<<<', pos)
		if start == -1
			error "patch(): No HEREDOC marker found"
		lParts.push line.substring pos, start
		lParts.push callBack(lLines)
		pos = start + 3

	if line.indexOf('<<<', pos) != -1
		n = numHereDocs(line)
		error "patch(): Not all #{n} HEREDOC markers were replaced" \
			+ "in '#{line}'"
	lParts.push line.substring pos, line.length
	return lParts.join('')

# ---------------------------------------------------------------------------

stdCallback = (lLines) ->

	return JSON.stringify(build(lLines))

# ---------------------------------------------------------------------------

export build = (lLines) ->

	# --- if lLines is empty or of length 0:
	#        returns empty string

	if not lLines?
		debug "build(): lLines undefined - return ''"
		return ''

	if lLines.length == 0
		debug "build(): lLines len = 0 - return ''"
		return ''

	# --- This removes whatever indentation is found on
	#     the first line from ALL lines
	debug JSON.stringify(lLines), "   UNDENT:"

	str = undentedBlock(lLines)

	if isTAML(str)
		debug "   TAML found - converting"
		return taml(str)
	else
		return str
