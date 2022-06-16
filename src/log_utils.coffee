# log_utils.coffee

import yaml from 'js-yaml'

import {
	assert, undef, isNumber, isInteger, isString, isHash, isFunction,
	escapeStr, sep_eq, sep_dash, pass, OL,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {
	tabify, untabify, indentation, indented,
	} from '@jdeighan/coffee-utils/indent'

# --- This logger only ever gets passed a single string argument
putstr = undef
doDebugLog = false

export stringify = undef
fourSpaces  = '    '

# ---------------------------------------------------------------------------

export dashes = (prefix, totalLen=64, ch='-') ->

	return prefix + ch.repeat(totalLen - prefix.length)

# ---------------------------------------------------------------------------

export debugLog = (flag=true) ->

	doDebugLog = flag
	if doDebugLog
		LOG "doDebugLog = #{flag}"
	return

# ---------------------------------------------------------------------------
# This is useful for debugging

export LOG = (lArgs...) ->

	[label, item] = lArgs
	if lArgs.length > 1
		# --- There's both a label and an item
		if (item == undef)
			console.log "#{label} = undef"
		else if (item == null)
			console.log "#{label} = null"
		else
			console.log sep_dash
			console.log "#{label}:"
			if isString(item)
				console.log untabify(item)
			else
				console.log untabify(orderedStringify(item))
			console.log sep_dash
	else
		console.log label
	return true   # to allow use in boolean expressions

# --- Use this instead to make it easier to remove all instances
export DEBUG = LOG   # synonym

# ---------------------------------------------------------------------------

export setStringifier = (func) ->

	orgStringifier = stringify
	assert isFunction(func), "setStringifier() arg is not a function"
	stringify = func
	return orgStringifier

# ---------------------------------------------------------------------------

export resetStringifier = () ->

	setStringifier orderedStringify

# ---------------------------------------------------------------------------

export setLogger = (func) ->

	assert isFunction(func), "setLogger() arg is not a function"
	orgLogger = putstr
	putstr = func
	return orgLogger

# ---------------------------------------------------------------------------

export resetLogger = () ->

	setLogger console.log

# ---------------------------------------------------------------------------

escReplacer = (name, value) ->

	if ! isString(value)
		return value
	return escapeStr(value)

# ---------------------------------------------------------------------------

export tamlStringify = (obj, escape=false) ->

	str = yaml.dump(obj, {
		skipInvalid: true
		indent: 1
		sortKeys: false
		lineWidth: -1
		replacer: if escape then escReplacer else (name,value) -> value
		})
	return "---\n" + tabify(str, 1)

# ---------------------------------------------------------------------------

export orderedStringify = (obj, escape=false) ->

	str = yaml.dump(obj, {
		skipInvalid: true
		indent: 1
		sortKeys: true
		lineWidth: 40
		replacer: if escape then escReplacer else (name,value) -> value
		})

	return "---\n" + tabify(str, 1)

# ---------------------------------------------------------------------------

maxOneLine = 32

# ---------------------------------------------------------------------------

export log = (str, hOptions={}) ->
	# --- valid options:
	#   prefix

	assert isString(str),      "log(): not a string: #{OL(str)}"
	assert isFunction(putstr), "putstr not properly set"
	assert isHash(hOptions),   "log(): arg 2 not a hash: #{OL(hOptions)}"
	prefix = fixForTerminal(hOptions.prefix)

	if doDebugLog
		LOG "CALL log(#{OL(str)}), prefix = #{OL(prefix)}"

	putstr "#{prefix}#{str}"
	return true   # to allow use in boolean expressions

# ---------------------------------------------------------------------------

export logItem = (label, item, hOptions={}) ->
	# --- valid options:
	#   prefix

	assert isFunction(putstr), "putstr not properly set"
	assert !label || isString(label), "label a non-string"
	assert isHash(hOptions), "arg 3 not a hash"

	label = fixForTerminal(label)
	prefix = fixForTerminal(hOptions.prefix)
	assert prefix.indexOf("\t") == -1, "prefix has TAB"

	if doDebugLog
		LOG "CALL logItem(#{OL(label)}, #{OL(item)})"
		LOG "prefix = #{OL(prefix)}"

	labelStr = if label then "#{label} = " else ""

	if (item == undef)
		putstr "#{prefix}#{labelStr}undef"
	else if (item == null)
		putstr "#{prefix}#{labelStr}null"
	else if isString(item)
		if (item.length <= maxOneLine)
			putstr "#{prefix}#{labelStr}'#{escapeStr(item)}'"
		else
			if label
				putstr "#{prefix}#{label}:"
			putBlock item, prefix + fourSpaces
	else if isNumber(item)
		putstr "#{prefix}#{labelStr}#{item}"
	else
		if label
			putstr "#{prefix}#{label}:"
		for str in blockToArray(stringify(item, true))  # escape special chars
			putstr "#{prefix + fourSpaces}#{fixForTerminal(str)}"

	return true

# ---------------------------------------------------------------------------

export shortEnough = (label, value) ->

	return (value == undef)

# ---------------------------------------------------------------------------
# --- needed because Windows Terminal handles TAB chars badly

fixForTerminal = (str) ->

	if !str
		return ''

	# --- convert TAB char to 4 spaces
	return str.replace(/\t/g, fourSpaces)

# ---------------------------------------------------------------------------

putBlock = (item, prefix='') ->

	putstr "#{prefix}#{sep_eq}"
	for line in blockToArray(item)
		putstr "#{prefix}#{escapeStr(line)}"
	putstr "#{prefix}#{sep_eq}"
	return

# ---------------------------------------------------------------------------

if ! loaded
	setStringifier orderedStringify
	resetLogger()
loaded = true
