# coffee_utils.coffee

import {strict as assert} from 'assert'
import yaml from 'js-yaml'

import {debug} from '@jdeighan/coffee-utils/debug'
import {tabify, untabify} from '@jdeighan/coffee-utils/indent'

export sep_dash = '-'.repeat(42)
export sep_eq = '='.repeat(42)
`export const undef = undefined`

export unitTesting = false
export setUnitTesting = (flag) -> unitTesting = flag

logger = console.log          # for strings

# ---------------------------------------------------------------------------
# the default stringifier

export tamlStringifier = (obj) ->

	str = yaml.dump(obj, {
			skipInvalid: true
			indent: 1
			sortKeys: false
			lineWidth: -1
			})
	str = "---\n" + tabify(str)
	str = str.replace(/\t/g, '   ')  # because fr***ing Windows Terminal
	                                 # has no way of adjusting display
	                                 # of TAB chars
	return str

# ---------------------------------------------------------------------------

stringifier = tamlStringifier # for non-strings

# ---------------------------------------------------------------------------

export setLogger = (func) ->

	if func?
		assert isFunction(func), "setLogger() not a function"
		logger = func
	else
		logger = console.log
	return

# ---------------------------------------------------------------------------

export setStringifier = (func) ->

	if func?
		assert isFunction(func), "setStringifier() not a function"
		stringifier = func
	else
		stringifier = tamlStringifier
	return

# ---------------------------------------------------------------------------

export currentLogger = () ->

	return logger

# ---------------------------------------------------------------------------

export currentStringifier = () ->

	return stringifier

# ---------------------------------------------------------------------------

export stringify = (item) ->

	assert isFunction(stringifier), "stringify(): stringifier not a function"
	return stringifier(item)

# ---------------------------------------------------------------------------
#   say - print to the console

export log = (obj, label='') ->

	if label
		logger titleLine(label)
	if not isString(obj)
		obj = stringifier(obj)
	logger obj
	return

# ---------------------------------------------------------------------------
#   say - print to the console

export say = (obj, label='') ->

	if label
		logger label
	if not isString(obj)
		obj = stringifier(obj)
	logger obj
	return

# ---------------------------------------------------------------------------
#   pass - do nothing

export pass = () ->

# ---------------------------------------------------------------------------
#   error - throw an error

export error = (message) ->

	throw new Error(message)

# ---------------------------------------------------------------------------
#   croak - throws an error after possibly printing useful info

export croak = (message, obj, label) ->

	log "ERROR: #{message}"
	if obj?
		log obj, label
	throw new Error(message)

# ---------------------------------------------------------------------------

export localStore = (key, value=undef) ->
	# --- if value is undef, returns the current value

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

export getClassName = (obj) ->

	if (typeof obj != 'object')
		return undef
	return obj.constructor.name

# ---------------------------------------------------------------------------

export isString = (x) ->

	return typeof x == 'string' || x instanceof String

# ---------------------------------------------------------------------------

export isNumber = (x) ->

	return typeof x == 'number' || x instanceof Number

# ---------------------------------------------------------------------------

export isObject = (x) ->

	return (typeof x == 'object') \
			&& not isString(x) \
			&& not isArray(x) \
			&& not isHash(x) \
			&& not isNumber(x)

# ---------------------------------------------------------------------------

export isArray = (x) ->

	return Array.isArray(x)

# ---------------------------------------------------------------------------

export isHash = (x) ->

	return (getClassName(x) == 'Object')

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

commentRegexp = /^\s*\#+(?:\s|$)/

# ---------------------------------------------------------------------------

export setCommentRegexp = (regexp) ->

	commentRegexp = regexp
	return

# ---------------------------------------------------------------------------

export isComment = (str) ->

	return if str.match(commentRegexp) then true else false

# ---------------------------------------------------------------------------

export words = (str) ->

	return str.trim().split(/\s+/)

# ---------------------------------------------------------------------------

export isArrayOfHashes = (lItems) ->

	if not isArray(lItems)
		return false
	for item in lItems
		if not isHash(item)
			return false
	return true

# ---------------------------------------------------------------------------

export isFunction = (x) ->

	return typeof x == 'function'

# ---------------------------------------------------------------------------

export isInteger = (x) ->

	if (typeof x == 'number')
		return Number.isInteger(x)
	else if (getClassName(x) == 'Number')
		return Number.isInteger(x.valueOf())
	else
		return false

# ---------------------------------------------------------------------------
#   warn - issue a warning

export warn = (message) ->

	say "WARNING: #{message}"

# ---------------------------------------------------------------------------
#   ask - ask a question

export ask = (prompt) ->

	return 'yes'

# ---------------------------------------------------------------------------

export firstLine = (input) ->

	if isArray(input)
		if (input.length==0)
			return undef
		return input[0]
	assert isString(input), "firstLine(): Not an array or string"
	pos = input.indexOf('\n')
	if (pos == -1)
		return input
	else
		return input.substring(0, pos)

# ---------------------------------------------------------------------------
#   stringToArray - split a string into lines

export stringToArray = (str) ->

	if isEmpty(str)
		return []
	else
		lLines = str.split(/\r?\n/)
		len = lLines.length
		while (len > 0) && isEmpty(lLines[len-1])
			lLines.pop()
			len -= 1
		return lLines

# ---------------------------------------------------------------------------
#   arrayToString - every line has trailing newline

export arrayToString = (lLines) ->

	if lLines.length == 0
		return ''
	else
		return rtrim(lLines.join('\n'))

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

export titleLine = (title, char='=', padding=2, linelen=42) ->
	# --- used in logger

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
#   rtrunc - strip nChars chars from right of a string

export rtrunc = (str, nChars) ->

	return str.substring(0, str.length - nChars)

# ---------------------------------------------------------------------------
#   ltrunc - strip nChars chars from left of a string

export ltrunc = (str, nChars) ->

	return str.substring(nChars)

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

export oneline = (obj) ->

	if isString(obj)
		return escapeStr(obj)
	else
		return JSON.stringify(obj)

# ---------------------------------------------------------------------------
# truncateBlock - limit block to a certain number of lines

export truncateBlock = (str, numLines) ->

	lLines = stringToArray str
	lLines.length = numLines
	return arrayToString lLines

# ---------------------------------------------------------------------------

export removeCR = (block) ->

	return block.replace(/\r/g, '')

# ---------------------------------------------------------------------------

export splitBlock = (block) ->

	block = removeCR(block)
	if pos = block.indexOf("\n")
		# --- pos is also the length of the 1st line
		#     2nd arg to substr() is number of characters to return
		return [block.substr(0, pos), block.substr(pos+1)]
	else
		return [block, '']

# ---------------------------------------------------------------------------

export CWS = (block) ->

	return block.trim().replace(/\s+/g, ' ')

# ---------------------------------------------------------------------------
