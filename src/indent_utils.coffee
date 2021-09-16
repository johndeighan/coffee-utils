# indent_utils.coffee

import {strict as assert} from 'assert'
import {
	undef, error, arrayToString, stringToArray, escapeStr,
	oneline, isInteger, isString, isArray, isEmpty, rtrim,
	} from '@jdeighan/coffee-utils'

# ---------------------------------------------------------------------------
#        NOTE: Currently, only TAB indentation is supported
# ---------------------------------------------------------------------------
#   splitLine - separate a line into {level, line}

export splitLine = (line) ->

	assert line?, "splitLine(): line is undef"
	assert (typeof line == 'string'), "splitLine(): line is not a string"
	line = rtrim(line)
	lMatches = line.match(/^(\s*)(.*)$/)
	return [lMatches[1].length, lMatches[2]]

# ---------------------------------------------------------------------------
#   indentation - return appropriate indentation string for given level
#   export only to allow unit testing

export indentation = (level) ->

	assert (level >= 0), "indented(): negative level"
	return '\t'.repeat(level)

# ---------------------------------------------------------------------------
#   indentLevel - determine indent level of a string

export indentLevel = (str) ->

	lMatches = str.match(/^\t*/)
	return lMatches[0].length

# ---------------------------------------------------------------------------
#   indented - add indentation to each string in a block

export indented = (input, level=0) ->

	assert (level >= 0), "indented(): negative level"
	if level == 0
		return input

	toAdd = indentation(level)
	if isArray(input)
		lLines = for line in input
			"#{toAdd}#{line}"
		return lLines
	else
		lLines = for line in stringToArray(input)
			"#{toAdd}#{line}"
		return arrayToString(lLines)

# ---------------------------------------------------------------------------
#   undented - string with 1st line indentation removed for each line
#            - unless level is set, in which case exactly that
#              indentation is removed
#            - returns same type as text, i.e. either string or array

export undented = (text, level=undef) ->

	if level? && (level==0)
		return text

	if isString(text)
		lLines = stringToArray(text)
		if (lLines.length == 0)
			return ''
	else if isArray(text)
		lLines = text
		if (lLines.length == 0)
			return []
	else
		error "undented(): Not an array or string: #{oneline(text)}"

	# --- determine what to remove from beginning of each line
	if level?
		assert isInteger(level), "undented(): level must be an integer"
		toRemove = indentation(level)
	else
		lMatches = lLines[0].match(/^\s*/)
		toRemove = lMatches[0]
	nToRemove = toRemove.length

	lNewLines = []
	for line in lLines
		if isEmpty(line)
			lNewLines.push('')
		else
			assert (line.indexOf(toRemove)==0),
				"undented(): Error removing '#{escapeStr(toRemove)}' \
					from '#{oneline(text)}'"
			lNewLines.push(line.substr(nToRemove))

	if isString(text)
		return arrayToString(lNewLines)
	else
		return lNewLines

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

	oneIndent = ' '.repeat(numSpaces)
	lLines = []
	for str in stringToArray(str)
		lMatches = str.match(/^(\t*)(.*)$/)
		[_, prefix, theRest] = lMatches
		if prefix == ''
			lLines.push theRest
		else
			lLines.push oneIndent.repeat(prefix.length) + theRest
	return arrayToString(lLines)
