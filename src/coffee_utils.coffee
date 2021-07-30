# coffee_utils.coffee

import yaml from 'js-yaml'

export sep_dash = '-'.repeat 42
export sep_eq = '='.repeat 42
`export const undef = undefined`

export getHello = () -> return "Hello, CoffeeScript!"

export unitTesting = false
export setUnitTesting = (flag=true) -> unitTesting = flag

export debugging = false
export setDebugging = (flag=false) -> debugging = flag

# ---------------------------------------------------------------------------

export defined = (item) ->

	return (item != undef) && (item != null)

# ---------------------------------------------------------------------------

export debug = (item, label=undef) ->

	if debugging
		if isString(item)
			say escapeStr(item), label
		else
			say item, label
	return

# ---------------------------------------------------------------------------

export localStore = (key, value=undef) ->

	if typeof localStorage == 'undefined'
		return
	if value?
		localStorage.setItem key, JSON.stringify(value)
		return
	else
		value = localStorage.getItem(key)
		if value?
			return JSON.parse(localStorage.getItem(key))
		else
			return undef

# ---------------------------------------------------------------------------
#   isEmpty
#      - string is whitespace, array has no elements, hash has no keys

export isEmpty = (x) ->

	if not x?
		return true
	if isString(x)
		return x.match(/^\s*$/)
	if isArray(x)
		return x.length == 0
	if isHash(x)
		return Object.keys(x).length == 0
	else
		error "isEmpty(): Invalid parameter"

# ---------------------------------------------------------------------------
#   nonEmpty
#      - string has non-whitespace, array has elements, hash has keys

export nonEmpty = (x) ->

	if not x?
		return false
	if isString(x)
		return not x.match(/^\s*$/)
	if isArray(x)
		return x.length > 0
	if isHash(x)
		return Object.keys(x).length > 0
	else
		error "isEmpty(): Invalid parameter"

# ---------------------------------------------------------------------------

export words = (str) ->

	return str.trim().split(/\s+/)

# ---------------------------------------------------------------------------

export isString = (x) ->

	return typeof x == 'string' || x instanceof String

# ---------------------------------------------------------------------------

export isObject = (x) ->

	return typeof x == 'object'

# ---------------------------------------------------------------------------

export isArray = (x) ->

	return Array.isArray(x)

# ---------------------------------------------------------------------------

export isHash = (x) ->

	return typeof x == 'object'

# ---------------------------------------------------------------------------
#   pass - do nothing

export pass = () ->

# ---------------------------------------------------------------------------
#   error - throw an error

export error = (message) ->

	throw new Error(message)

# ---------------------------------------------------------------------------
#   say - print to the console

export say = (str, label='') ->
	if label
		console.log label
	if typeof str == 'object'
		console.dir str
	else
		console.log str

# ---------------------------------------------------------------------------
#   ask - ask a question

export ask = (prompt) ->

	return 'yes'

# ---------------------------------------------------------------------------
#   isTAML - is the string valid TAML?

export isTAML = (str) ->
	if typeof str == 'object'
		if not str || str.length == 0
			return false
		return str[0].indexOf('---') == 0
	return str.indexOf('---') == 0

# ---------------------------------------------------------------------------
#   taml - convert valid TAML string to a data structure

export taml = (strOrArray) ->

	if not strOrArray
		return 'null'
	if typeof strOrArray == 'object'
		strOrArray = arrayToString(strOrArray)
	return yaml.load(strOrArray.replace(/\t/g, '  '))

# ---------------------------------------------------------------------------
#   stringToArray - split a string into lines

export stringToArray = (str) ->

	if isEmpty(str)
		return []
	else
		return str.split(/\r?\n/)

# ---------------------------------------------------------------------------
#   arrayToString - every line has trailing newline

export arrayToString = (lLines) ->

	if lLines.length == 0
		return ''
	else
		return rtrim(lLines.join('\n')) + '\n'

# ---------------------------------------------------------------------------
#   normalize - remove blank lines, trim each line
#             - collapse internal whitespace to ' '

export normalize = (content) ->

	if typeof content != 'string'
		throw new Error("normalize(): not a string")
	lLines = for line in stringToArray(content)
		line = line.trim()
		line.replace(/\s+/g, ' ')
	lLines = lLines.filter (line) -> line != ''
	return lLines.join('\n')

# ---------------------------------------------------------------------------
#   dumpOutput - for debugging
#      --- output can be a string or an array

export dumpOutput = (output, label="output", logger=console.log) ->

	logger sep_eq
	logger titleLine(label)
	logger sep_eq
	if typeof output == 'string'
		logger output
	else if typeof output == 'object'
		for line in output
			logger line

# ---------------------------------------------------------------------------

export titleLine = (title, char='=', padding=2, linelen=42) ->

	titleLen = title.length + 2 * padding
	nLeft = Math.floor((linelen - titleLen) / 2)
	nRight = linelen - nLeft - titleLen
	strLeft = char.repeat(nLeft)
	strMiddle = ' '.repeat(padding) + title + ' '.repeat(padding)
	strRight = char.repeat(nRight)
	return strLeft + strMiddle + strRight

# ---------------------------------------------------------------------------
#   rtrim - strip trailing whitespace

export rtrim = (line) ->
	lMatches = line.match(/\s+$/)
	if lMatches?
		n = lMatches[0].length   # num chars to remove
		return line.substring(0, line.length - n)
	else
		return line

# ---------------------------------------------------------------------------
#   deepCopy - deep copy an array or object

export deepCopy = (obj) ->

	return JSON.parse(JSON.stringify(obj))

# ---------------------------------------------------------------------------
#   escapeStr - escape newlines, TAB chars, etc.

export escapeStr = (str) ->

	if not str?
		return 'undef'
	if typeof str != 'string'
		say "STRING: '#{str}'"
		error "escapeStr(): not a string"
	lParts = for ch in str.split('')
		if ch == '\n'
			'\\n'
		else if ch == '\t'
			'\\t'
		else
			ch
	return lParts.join('')

# ---------------------------------------------------------------------------
# truncateBlock - limit block to a certain number of lines

export truncateBlock = (str, numLines) ->

	lLines = stringToArray str
	lLines.length = numLines
	return arrayToString lLines
