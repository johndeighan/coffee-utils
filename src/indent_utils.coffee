# indent_utils.coffee

import {undef, error, arrayToString} from './coffee_utils.js'

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
#   indentedStr - add indentation to a string

export indentedStr = (str, level=0) ->

	if typeof str != 'string'
		throw new Error("indentedStr(): not a string")
	return indentation(level) + str

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
#   undentedStr - remove indentation from a simple string
#                 i.e. it should NOT include any newline chars
#      if level is provided, only that level of indentation is removed

export undentedStr = (str, level=undef) ->

	if level?
		return str.substring(level)
	else
		# --- this will always match
		lMatches = str.match(/^\s*(.*)$/)
		return lMatches[1]

# ---------------------------------------------------------------------------
#   undentedBlock - string with 1st line indentation removed for each line
#            - you can pass in an array, but result is always a string

export undentedBlock = (strOrArray) ->

	if not strOrArray?
		return ''
	isType = typeof strOrArray
	if isType == 'object'
		lLines = strOrArray      # it's really an array
		if lLines.length == 0
			return ''

		# --- Check for a prefix on the 1st line
		lMatches = lLines[0].match(/^(\s+)/)
		if not lMatches?
			return arrayToString(lLines)

		prefix = lMatches[1]
		prefixLen = prefix.length
		lStripped = for str in lLines
			if str.indexOf(prefix) == 0
				str.substring(prefixLen)
			else
				str
		return arrayToString(lStripped)
	else if isType == 'string'
		# --- It's a string - split, undent, then reassemble
		return undentedBlock(strOrArray.split(/\r?\n/))
	else
		throw new Error("undentedBlock(): #{isType} is not an array or string")

# ---------------------------------------------------------------------------
#   indentedBlock - add indentation to each string in a block

export indentedBlock = (content, level=0) ->

	if typeof content != 'string'
		error "indentedBlock(): not a string"
	if level == 0
		return content

	indent = '\t'.repeat(level)
	lLines = for line in content.split(/\r?\n/)
		if line then "#{indent}#{line}" else ""
	result = lLines.join('\n')
	return result

