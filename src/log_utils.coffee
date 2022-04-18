# log_utils.coffee

import yaml from 'js-yaml'

import {
	assert, undef, isNumber, isInteger, isString, isHash, isFunction,
	escapeStr, sep_eq, sep_dash, pass
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {tabify, untabify, indentation} from '@jdeighan/coffee-utils/indent'

# --- This logger only ever gets passed a single string argument
putstr = undef

export stringify = undef

# ---------------------------------------------------------------------------
# This is useful for debugging

export LOG = (lArgs...) ->

	[label, item] = lArgs
	if lArgs.length > 1
		console.log sep_dash
		if item?
			console.log "#{label}:"
			console.log untabify(orderedStringify(item))
		else
			console.log "#{label}: UNDEFINED"
		console.log sep_dash
	else
		console.log label
	return

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

fixStr = (str) ->

	if !str
		return ''

	# --- If putstr is console.log, we'll convert TAB char to 3 spaces
	if putstr == console.log
		return untabify(str)
	else
		return str

# ---------------------------------------------------------------------------

export log = (str, hOptions={}) ->
	# --- valid options:
	#   prefix

	assert isFunction(putstr), "putstr not properly set"
	assert isString(str),      "log(): not a string"
	assert isHash(hOptions),   "log(): arg 2 not a hash"

	prefix = fixStr(hOptions.prefix)
	putstr "#{prefix}#{str}"
	return

# ---------------------------------------------------------------------------

export logItem = (label, item, hOptions={}) ->
	# --- valid options:
	#   prefix     - not used
	#   itemPrefix - always used

	assert isFunction(putstr), "putstr not properly set"
	assert !label || isString(label), "label a non-string"
	assert isHash(hOptions), "arg 3 not a hash"

	label = fixStr(label)
	prefix = fixStr(hOptions.itemPrefix || hOptions.prefix)
	labelStr = if label then "#{label} = " else ""

	if (item == undef)
		putstr "#{prefix}#{labelStr}undef"
	else if isString(item)
		if (item.length <= maxOneLine)
			putstr "#{prefix}#{labelStr}'#{escapeStr(item)}'"
		else
			if label
				putstr "#{prefix}#{label}:"
			putBlock item, prefix
	else if isNumber(item)
		putstr "#{prefix}#{labelStr}#{item}"
	else
		putstr "#{prefix}#{sep_dash}"
		if label
			putstr "#{prefix}#{label}:"
		for str in blockToArray(stringify(item, true))  # escape special chars
			putstr "#{prefix}#{indentation(1)}#{fixStr(str)}"
		putstr "#{prefix}#{sep_dash}"

	return

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
