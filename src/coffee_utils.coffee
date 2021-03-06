# coffee_utils.coffee

export sep_dash = '-'.repeat(42)
export sep_eq = '='.repeat(42)
`export const undef = undefined`
LOG = (lArgs...) -> console.log lArgs...   # synonym for console.log()

export doHaltOnError = false

# ---------------------------------------------------------------------------
# TEMP!!!!!

export isComment = (line) ->

	lMatches = line.match(///^
			\s*
			\#
			(\s|$)
			///)
	return defined(lMatches)

# ---------------------------------------------------------------------------

export eval_expr = (str) ->

	str = str.replace(/\bundef\b/g, 'undefined')
	return Function('"use strict";return (' + str + ')')();

# ---------------------------------------------------------------------------

export haltOnError = () ->

	doHaltOnError = true

# ---------------------------------------------------------------------------
#   pass - do nothing

export pass = () ->

# ---------------------------------------------------------------------------
#   error - throw an error

export error = (message) ->

	if doHaltOnError
		console.trace("ERROR: #{message}")
		process.exit()
	throw new Error(message)

# ---------------------------------------------------------------------------

getCallers = (stackTrace, lExclude=[]) ->

	iter = stackTrace.matchAll(///
			at
			\s+
			(?:
				async
				\s+
				)?
			([^\s(]+)
			///g)
	if !iter
		return ["<unknown>"]

	lCallers = []
	for lMatches from iter
		[_, caller] = lMatches
		if (caller.indexOf('file://') == 0)
			break
		if caller not in lExclude
			lCallers.push caller

	return lCallers

# ---------------------------------------------------------------------------
#   assert - mimic nodejs's assert
#   return true so we can use it in boolean expressions

export assert = (cond, msg) ->

	if ! cond
		stackTrace = new Error().stack
		lCallers = getCallers(stackTrace, ['assert'])

		console.log '--------------------'
		console.log 'JavaScript CALL STACK:'
		for caller in lCallers
			console.log "   #{caller}"
		console.log '--------------------'
		console.log "ERROR: #{msg} (in #{lCallers[0]}())"
		if doHaltOnError
			process.exit()
		error msg
	return true

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

export patchStr = (bigstr, pos, str) ->

	endpos = pos + str.length
	if (endpos < bigstr.length)
		return bigstr.substring(0, pos) + str + bigstr.substring(endpos)
	else
		return bigstr.substring(0, pos) + str

# ---------------------------------------------------------------------------

export isString = (x) ->

	return typeof x == 'string' || x instanceof String

# ---------------------------------------------------------------------------

export isNonEmptyString = (x) ->

	if typeof x != 'string' && x ! instanceof String
		return false
	if x.match(/^\s*$/)
		return false
	return true

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

export isNonEmptyArray = (x) ->

	return isArray(x) && (x.length > 0)

# ---------------------------------------------------------------------------

export isHash = (x, lKeys) ->

	if ! x || (getClassName(x) != 'Object')
		return false
	if defined(lKeys)
		assert isArray(lKeys), "isHash(): lKeys not an array"
		for key in lKeys
			if ! x.hasOwnProperty(key)
				return false
	return true

# ---------------------------------------------------------------------------

export isNonEmptyHash = (x) ->

	return isHash(x) && (Object.keys(x).length > 0)

# ---------------------------------------------------------------------------

export hashHasKey = (x, key) ->

	assert isHash(x), "hashHasKey(): not a hash"
	assert isString(key), "hashHasKey(): key not a string"
	return x.hasOwnProperty(key)

# ---------------------------------------------------------------------------
#   isEmpty
#      - string is whitespace, array has no elements, hash has no keys

export isEmpty = (x) ->

	if (x == undef) || (x == null)
		return true
	if isString(x)
		return x.match(/^\s*$/)
	if isArray(x)
		return x.length == 0
	if isHash(x)
		return Object.keys(x).length == 0
	else
		return false

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

export isUniqueList = (lItems, func=undef) ->

	if ! lItems?
		return true     # empty list is unique
	if defined(func)
		assert isFunction(func), "Not a function: #{OL(func)}"
	h = {}
	for item in lItems
		if defined(func) && !func(item)
			return false
		if defined(h[item])
			return false
		h[item] = 1
	return true

# ---------------------------------------------------------------------------

export isUniqueTree = (lItems, func=undef, hFound={}) ->

	if isEmpty(lItems)
		return true     # empty list is unique
	if defined(func)
		assert isFunction(func), "Not a function: #{OL(func)}"
	for item in lItems
		if isArray(item)
			if ! isUniqueTree(item, func, hFound)
				return false
		else
			if defined(func) && !func(item)
				return false
			if defined(hFound[item])
				return false
			hFound[item] = 1
	return true

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
		LOG hashToStr(x)
	else
		LOG x
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

	if (obj == undef)
		return undef
	objStr = JSON.stringify(obj)
	try
		newObj = JSON.parse(objStr)
	catch err
		croak "ERROR: err.message", objStr

	return newObj

# ---------------------------------------------------------------------------
#   escapeStr - escape newlines, TAB chars, etc.

export hDefEsc = {
	"\n": '??'
	"\t": '???'
	" ": '??'
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

# ---------------------------------------------------------------------------

export replaceVars = (line, hVars={}, rx=/__(env\.)?([A-Za-z_]\w*)__/g) ->

	assert isHash(hVars), "replaceVars() hVars is not a hash"

	replacerFunc = (match, prefix, name) =>
		if prefix
			return process.env[name]
		else
			value = hVars[name]
			if defined(value)
				if isString(value)
					return value
				else
					return JSON.stringify(value)
			else
				return "__#{name}__"
	return line.replace(rx, replacerFunc)

# ---------------------------------------------------------------------------

export defined = (obj) ->

	return (obj != undef) && (obj != null)

# ---------------------------------------------------------------------------

export notdefined = (obj) ->

	return (obj == undef) || (obj == null)

# ---------------------------------------------------------------------------

export isIterable = (obj) ->

	if (obj == undef) || (obj == null)
		return false
	return typeof obj[Symbol.iterator] == 'function'

# ---------------------------------------------------------------------------

export className = (aClass) ->

	if lMatches = aClass.toString().match(/class\s+(\w+)/)
		return lMatches[1]
	else
		croak "className(): Bad input class"

# ---------------------------------------------------------------------------

export range = (n) ->

	return [0..n-1]

# ---------------------------------------------------------------------------

export setCharsAt = (str, pos, str2) ->

	assert (pos >= 0), "negative pos #{pos} not allowed"
	assert (pos < str.length), "pos #{pos} not in #{OL(str)}"
	if (pos + str2.length >= str.length)
		return str.substring(0, pos) + str2
	else
		return str.substring(0, pos) + str2 + str.substring(pos + str2.length)

