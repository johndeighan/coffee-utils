# indent_utils.coffee

import {
	assert, undef, error, escapeStr, defined,
	OL, isInteger, isString, isArray, isEmpty, rtrim,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock, blockToArray} from '@jdeighan/coffee-utils/block'

# ---------------------------------------------------------------------------

export splitPrefix = (line) ->

	assert isString(line), "non-string #{OL(line)}"
	line = rtrim(line)
	lMatches = line.match(/^(\s*)(.*)$/)
	return [lMatches[1], lMatches[2]]

# ---------------------------------------------------------------------------
#   splitLine - separate a line into [level, line]

export splitLine = (line, oneIndent="\t") ->

	[prefix, str] = splitPrefix(line)
	return [indentLevel(prefix, oneIndent), str]

# ---------------------------------------------------------------------------
#   indentation - return appropriate indentation string for given level
#   export only to allow unit testing

export indentation = (level, oneIndent="\t") ->

	assert (level >= 0), "indentation(): negative level"
	return oneIndent.repeat(level)

# ---------------------------------------------------------------------------
#   indentLevel - determine indent level of a string
#                 it's OK if the string is ONLY indentation

export indentLevel = (line, oneIndent="\t") ->

	len = oneIndent.length

	# --- This will always match
	if lMatches = line.match(/^(\s*)/)
		prefix = lMatches[1]
		prefixLen = prefix.length

	remain = prefixLen % len
	if (remain != 0)
		throw new Error("prefix #{OL(prefix)} not a mult of #{OL(oneIndent)}")

	level = prefixLen / len
	if (prefix != oneIndent.repeat(level))
		throw new Error("prefix #{OL(prefix)} not a mult of #{OL(oneIndent)}")

	return level

# ---------------------------------------------------------------------------
#   isUndented - true iff indentLevel(line) == 0

export isUndented = (line) ->

	assert isString(line), "non-string #{OL(line)}"
	lMatches = line.match(/^\s*/)
	return (lMatches[0].length == 0)

# ---------------------------------------------------------------------------
#   indented - add indentation to each string in a block

export indented = (input, level=1, oneIndent="\t") ->

	assert (level >= 0), "indented(): negative level"
	if level == 0
		return input

	toAdd = indentation(level, oneIndent)
	if isArray(input)
		lInputLines = input
	else
		lInputLines = blockToArray(input)

	lLines = for line in lInputLines
		if isEmpty(line)
			""
		else
			"#{toAdd}#{line}"
	return arrayToBlock(lLines)

# ---------------------------------------------------------------------------
#   undented - string with 1st line indentation removed for each line
#            - unless level is set, in which case exactly that
#              indentation is removed
#            - returns same type as text, i.e. either string or array

export undented = (text, level=undef, oneIndent="\t") ->

	if defined(level) && (level==0)
		return text

	if isString(text)
		lLines = blockToArray(text)
		if (lLines.length == 0)
			return ''
	else if isArray(text)
		lLines = text
		for line in lLines
			assert isString(line), "undented(): array not all strings"
		if (lLines.length == 0)
			return []
	else
		error "undented(): Not an array or string: #{OL(text)}"

	# --- determine what to remove from beginning of each line
	if defined(level)
		assert isInteger(level), "undented(): level must be an integer"
		toRemove = indentation(level, oneIndent)
	else
		lMatches = lLines[0].match(/^\s*/)
		toRemove = lMatches[0]
	nToRemove = indentLevel(toRemove)

	lNewLines = []
	for line in lLines
		if isEmpty(line)
			lNewLines.push('')
		else
			if (line.indexOf(toRemove) != 0)
				throw new Error("remove #{OL(toRemove)} from #{OL(text)}")
			lNewLines.push(line.substr(nToRemove))

	if isString(text)
		return arrayToBlock(lNewLines)
	else
		return lNewLines

# ---------------------------------------------------------------------------
#    tabify - convert leading spaces to TAB characters
#             if numSpaces is not defined, then the first line
#             that contains at least one space sets it

export tabify = (str, numSpaces=undef) ->

	lLines = []
	for str in blockToArray(str)
		[_, prefix, theRest] = str.match(/^(\s*)(.*)$/)
		prefixLen = prefix.length
		if prefixLen == 0
			lLines.push theRest
		else
			assert (prefix.indexOf('\t') == -1), "found TAB"
			if numSpaces == undef
				numSpaces = prefixLen
			assert (prefixLen % numSpaces == 0), "Bad prefix"
			level = prefixLen / numSpaces
			lLines.push '\t'.repeat(level) + theRest
	result = arrayToBlock(lLines)
	return result

# ---------------------------------------------------------------------------
#    untabify - convert ALL TABs to spaces

export untabify = (str, numSpaces=3) ->

	return str.replace(/\t/g, ' '.repeat(numSpaces))

# ---------------------------------------------------------------------------
#    enclose - indent text, surround with pre and post

export enclose = (text, pre, post) ->

	return pre + "\n" + indented(text) + "\n" + post
