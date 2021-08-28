# indent_utils.coffee

import {strict as assert} from 'assert'
import {
	undef, error, arrayToString, stringToArray, escapeStr, isInteger,
	} from '@jdeighan/coffee-utils'

# ---------------------------------------------------------------------------
#        NOTE: Currently, only TAB indentation is supported
# ---------------------------------------------------------------------------
#   splitLine - separate a line into {level, line}

export splitLine = (line) ->

	if not line?
		throw new Error("splitLine(): line is undef")
	if typeof line != 'string'
		throw new Error("splitLine(): line is not a string")
	lMatches = line.match(/^(\s*)(.*)$/)
	return [lMatches[1].length, lMatches[2].trim()]

# ---------------------------------------------------------------------------
#   indentation - return appropriate indentation string for given level

export indentation = (level) ->

	return '\t'.repeat(level)

# ---------------------------------------------------------------------------
#   indentLevel - determine indent level of a string

export indentLevel = (str) ->

	lMatches = /^\t*/.exec(str)
	return lMatches[0].length

# ---------------------------------------------------------------------------
#   indented - add indentation to each string in a block

export indented = (str, level=0) ->

	assert (typeof str == 'string'), "indented(): not a string"
	if level == 0
		return str

	toAdd = indentation(level)
	lLines = for line in stringToArray(str)
		"#{toAdd}#{line}"
	return arrayToString(lLines)

# ---------------------------------------------------------------------------
#   undented - string with 1st line indentation removed for each line
#            - unless level is set, in which case exactly that
#              indentation is removed

export undented = (str, level=undef) ->

	assert (typeof str == 'string'), "undented(): not a string"
	if not str? || (str == '')
		return ''

	# --- split, undent, then reassemble
	lLines = stringToArray(str)
	if lLines.length == 0
		return ''

	# --- determine what to remove from beginning of each line
	if level?
		assert isInteger(level), "undented(): level must be an integer"
		toRemove = indentation(level)
	else
		lMatches = lLines[0].match(/^\s*/)
		toRemove = lMatches[0]
	nToRemove = toRemove.length

	lNewLines = for line in lLines
		assert (line.indexOf(toRemove)==0),
			"undented(): '#{escapeStr(line)}' does not start with '#{escapeStr(toRemove)}'"
		line.substr(nToRemove)

	return arrayToString(lNewLines)

# ---------------------------------------------------------------------------
#    tabify - convert leading spaces to TAB characters
#             if numSpaces is not defined, then the first line
#             that contains at least one space sets it

export tabify = (str, numSpaces=undef) ->

	lLines = []
	for str in stringToArray(str)
		lMatches = str.match(/^(\s*)(.*)$/)
		[_, prefix, theRest] = lMatches
		if prefix == ''
			lLines.push theRest
		else
			n = prefix.length
			if (prefix.indexOf('\t') != -1)
				error "tabify(): leading TAB characters not allowed"
			if not numSpaces?
				numSpaces = n
			if (n % numSpaces != 0)
				error "tabify(): Invalid # of leading space chars"
			lLines.push '\t'.repeat(n / numSpaces) + theRest
	return arrayToString(lLines)

# ---------------------------------------------------------------------------
#    untabify - convert leading TABs to spaces

export untabify = (str, numSpaces=3) ->

	lLines = []
	for str in stringToArray(str)
		lMatches = str.match(/^(\s*)(.*)$/)
		[_, prefix, theRest] = lMatches
		if prefix == ''
			lLines.push theRest
		else
			n = prefix.length
			if (prefix != '\t'.repeat(n))
				error "untabify(): not all TABs: prefix='#{escapeStr(prefix)}'"
			lLines.push ' '.repeat(n * numSpaces) + theRest
	return arrayToString(lLines)
