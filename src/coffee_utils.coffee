# coffee_utils.coffee

import getline from 'readline-sync'
import {log} from '@jdeighan/coffee-utils/log'

export sep_dash = '-'.repeat(42)
export sep_eq = '='.repeat(42)
`export const undef = undefined`

# ---------------------------------------------------------------------------
#   pass - do nothing

export pass = () ->

# ---------------------------------------------------------------------------
#   error - throw an error

export error = (message) ->

	throw new Error(message)

# ---------------------------------------------------------------------------
#   assert - mimic nodejs's assert

export assert = (cond, msg) ->

	if ! cond
		error(msg)
	return

# ---------------------------------------------------------------------------
#   croak - throws an error after possibly printing useful info

export croak = (err, label, obj) ->

	message = if (typeof err == 'object') then err.message else err
	log "ERROR: #{message}"
	log label, obj
	if (typeof err == 'object')
		throw err
	else
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
			&& ! isString(x) \
			&& ! isArray(x) \
			&& ! isHash(x) \
			&& ! isNumber(x)

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

	if ! x?
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

	if ! x?
		return false
	if isString(x)
		return ! x.match(/^\s*$/)
	if isArray(x)
		return x.length > 0
	if isHash(x)
		return Object.keys(x).length > 0
	else
		error "isEmpty(): Invalid parameter"

# ---------------------------------------------------------------------------

commentRegExp = /^\s*\#+(?:\s|$)/

# ---------------------------------------------------------------------------

export setCommentRegexp = (regexp) ->

	commentRegExp = regexp
	return

# ---------------------------------------------------------------------------

export isComment = (str) ->

	return if str.match(commentRegExp) then true else false

# ---------------------------------------------------------------------------

export words = (str) ->

	return str.trim().split(/\s+/)

# ---------------------------------------------------------------------------

export isArrayOfHashes = (lItems) ->

	if ! isArray(lItems)
		return false
	for item in lItems
		if ! isHash(item)
			return false
	return true

# ---------------------------------------------------------------------------

export isArrayOfStrings = (lItems) ->

	if ! isArray(lItems)
		return false
	for item in lItems
		if ! isString(item)
			return false
	return true

# ---------------------------------------------------------------------------

export isFunction = (x) ->

	return typeof x == 'function'

# ---------------------------------------------------------------------------

export isRegExp = (x) ->

	return x instanceof RegExp

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

	log "WARNING: #{message}"

# ---------------------------------------------------------------------------
#   say - print to the console (for now)
#         later, on a web page, call alert(str)

export say = (str) ->

	console.log str
	return

# ---------------------------------------------------------------------------
#   ask - ask a question
#         later, on a web page, prompt the user for answer to question

export ask = (prompt) ->

	answer = getline.question("{prompt}? ")
	return answer

# ---------------------------------------------------------------------------

export titleLine = (title, char='=', padding=2, linelen=42) ->
	# --- used in logger

	if ! title
		return char.repeat(linelen)

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

export escapeStr = (str, hEscape=undef) ->

	if ! isString(str)
		croak "escapeStr(): not a string", str, 'STRING'
	if hEscape?
		lParts = for ch in str.split('')
			if hEscape[ch]?
				hEscape[ch]
			else
				ch
	else
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

	if obj?
		if isString(obj)
			return "'#{escapeStr(obj)}'"
		else
			return JSON.stringify(obj)
	else
		return 'undef'

export OL = oneline

# ---------------------------------------------------------------------------

export removeCR = (str) ->

	return str.replace(/\r/g, '')

# ---------------------------------------------------------------------------

export CWS = (str) ->

	assert isString(str), "CWS(): parameter not a string"
	return str.trim().replace(/\s+/sg, ' ')

# ---------------------------------------------------------------------------

export extractMatches = (line, regexp, convertFunc=undef) ->

	lStrings = [...line.matchAll(regexp)]
	lStrings = for str in lStrings
		str[0]
	if convertFunc?
		lConverted = for str in lStrings
			convertFunc(str)
		return lConverted
	else
		return lStrings

# ---------------------------------------------------------------------------
