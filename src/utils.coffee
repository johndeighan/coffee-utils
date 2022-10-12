# utils.coffee

import {assert, croak} from '@jdeighan/exceptions'
import {LOG, sep_dash, sep_eq} from '@jdeighan/exceptions/log'
import {
	undef, pass, defined, notdefined,
	deepCopy, escapeStr, unescapeStr, hasChar, quoted, OL,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isConstructor, isFunction, isRegExp, isObject, getClassName,
	jsType,
	isEmpty, nonEmpty, chomp, rtrim, setCharsAt, words,
	} from '@jdeighan/exceptions/utils'

export {
	undef, pass, defined, notdefined, sep_dash, sep_eq,
	deepCopy, escapeStr, unescapeStr, hasChar, quoted, OL,
	isString, isNumber, isInteger, isHash, isArray, isBoolean,
	isConstructor, isFunction, isRegExp, isObject, getClassName,
	jsType,
	isEmpty, nonEmpty, chomp, rtrim, setCharsAt, words,
	}

# ---------------------------------------------------------------------------
# TEMP!!!!!

export isComment = (line) =>

	lMatches = line.match(///^
			\s*
			\#
			(\s|$)
			///)
	return defined(lMatches)

# ---------------------------------------------------------------------------

export isSubclassOf = (subClass, superClass) ->

	return (subClass == superClass) \
		|| (subClass.prototype instanceof superClass)

# ---------------------------------------------------------------------------

export eval_expr = (str) ->

	str = str.replace(/\bundef\b/g, 'undefined')
	return Function('"use strict";return (' + str + ')')();

# ---------------------------------------------------------------------------

export patchStr = (bigstr, pos, str) ->

	endpos = pos + str.length
	if (endpos < bigstr.length)
		return bigstr.substring(0, pos) + str + bigstr.substring(endpos)
	else
		return bigstr.substring(0, pos) + str

# ---------------------------------------------------------------------------

export charCount = (str, ch) ->

	count = 0
	pos = str.indexOf(ch, 0)
	while (pos >= 0)
		count += 1
		pos = str.indexOf(ch, pos+1)
	return count

# ---------------------------------------------------------------------------

export oneof = (word, lWords...) ->

	return (lWords.indexOf(word) >= 0)

# ---------------------------------------------------------------------------

export isNonEmptyString = (x) ->

	if typeof x != 'string' && x ! instanceof String
		return false
	if x.match(/^\s*$/)
		return false
	return true

# ---------------------------------------------------------------------------

export isNonEmptyArray = (x) ->

	return isArray(x) && (x.length > 0)

# ---------------------------------------------------------------------------

export isNonEmptyHash = (x) ->

	return isHash(x) && (Object.keys(x).length > 0)

# ---------------------------------------------------------------------------

export hashHasKey = (x, key) ->

	assert isHash(x), "hashHasKey(): not a hash"
	assert isString(key), "hashHasKey(): key not a string"
	return x.hasOwnProperty(key)

# ---------------------------------------------------------------------------

export notInArray = (lItems, item) ->

	return (lItems.indexOf(item) == -1)

# ---------------------------------------------------------------------------

export pushCond = (lItems, item, doPush=notInArray) ->

	if doPush(lItems, item)
		lItems.push item
		return true
	else
		return false

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
#   rtrunc - strip nChars chars from right of a string

export rtrunc = (str, nChars) ->

	return str.substring(0, str.length - nChars)

# ---------------------------------------------------------------------------
#   ltrunc - strip nChars chars from left of a string

export ltrunc = (str, nChars) ->

	return str.substring(nChars)

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

export getOptions = (hOptions, hDefault={}) ->
	# --- If hOptions is a string, break into words and set each to true

	if isString(hOptions)
		h = {}
		for word in words(hOptions)
			h[word] = true
		return h
	else if isHash(hOptions)
		return hOptions
	else
		return hDefault

# ---------------------------------------------------------------------------

export timestamp = () ->

	return new Date().toLocaleTimeString("en-US")
