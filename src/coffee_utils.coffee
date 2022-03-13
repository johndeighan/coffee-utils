# coffee_utils.coffee

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

	curmsg = if isString(err) then err else err.message
	newmsg = """
			ERROR (croak): #{curmsg}
			#{label}:
			#{JSON.stringify(obj)}
			"""

	# --- re-throw the error
	throw new Error(newmsg)

# ---------------------------------------------------------------------------

export getClassName = (obj) ->

	if (typeof obj != 'object')
		return undef
	return obj.constructor.name

# ---------------------------------------------------------------------------

export isString = (x) ->

	return typeof x == 'string' || x instanceof String

# ---------------------------------------------------------------------------

export isBoolean = (x) ->

	return typeof x == 'boolean'

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

export hashHasKey = (x, key) ->

	assert isHash(x), "hashHasKey(): not a hash"
	assert isString(key), "hashHasKey(): key not a string"
	return x.hasOwnProperty(key)

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

	assert isString(str), "isComment(): not a string"
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

export uniq = (lItems) ->

	return [...new Set(lItems)]

# ---------------------------------------------------------------------------
#   warn - issue a warning

export warn = (message) ->

	say "WARNING: #{message}"

# ---------------------------------------------------------------------------
#   hashToStr - stringify a hash

export hashToStr = (h) ->

	return JSON.stringify(h, Object.keys(h).sort(), 3)

# ---------------------------------------------------------------------------
#   say - print to the console (for now)
#         later, on a web page, call alert(str)

export say = (x) ->

	if isHash(x)
		console.log hashToStr(x)
	else
		console.log x
	return

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

	assert isString(line), "rtrim(): line is not a string"
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

export hDefEsc = {
	"\n": '®'
	"\t": '→'
	" ": '˳'
	}

export escapeStr = (str, hEscape=hDefEsc) ->

	assert isString(str), "escapeStr(): not a string"
	lParts = for ch in str.split('')
		if hEscape[ch]? then hEscape[ch] else ch
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

export envVarsWithPrefix = (prefix, hOptions={}) ->
	# --- valid options:
	#        stripPrefix

	assert prefix, "envVarsWithPrefix: empty prefix!"
	plen = prefix.length
	h = {}
	for key in Object.keys(process.env)
		if key.indexOf(prefix) == 0
			if hOptions.stripPrefix
				h[key.substr(plen)] = process.env[key]
			else
				h[key] = process.env[key]
	return h

# ---------------------------------------------------------------------------

export getTimeStr = (date=undef) ->

	if date == undef
		date = new Date()
	return date.toLocaleTimeString('en-US')

# ---------------------------------------------------------------------------

export getDateStr = (date=undef) ->

	if date == undef
		date = new Date()
	return date.toLocaleDateString('en-US')

# ---------------------------------------------------------------------------

export strcat = (lItems...) ->
	str = ''
	for item in lItems
		str += item.toString()
	return str
