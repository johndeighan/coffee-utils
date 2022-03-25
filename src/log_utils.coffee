# log_utils.coffee

import yaml from 'js-yaml'

import {
	assert, undef, isNumber, isInteger, isString, isHash, isFunction,
	escapeStr, sep_eq, sep_dash
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {tabify, untabify} from '@jdeighan/coffee-utils/indent'

# --- This logger only ever gets passed a single string argument
logger = undef
export stringify = undef
export id = 42

# ---------------------------------------------------------------------------
# This is useful for debugging and easy to remove after debugging

export LOG = (label, item, ch='=') ->

	if item
		console.log ch.repeat(42)
		console.log "[#{label}]:"
		console.log untabify(orderedStringify(item))
		console.log ch.repeat(42)
	else
		console.log label
	return

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

	orgLogger = logger
	assert isFunction(func), "setLogger() arg is not a function"
	logger = func
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
		lineWidth: -1
		replacer: if escape then escReplacer else (name,value) -> value
		})

	return "---\n" + tabify(str, 1)

# ---------------------------------------------------------------------------

maxOneLine = 32

# ---------------------------------------------------------------------------

export log = (item, hOptions=undef) ->
	# --- valid options:
	#        label
	#        prefix
	#        escape

	assert isFunction(logger), "logger not properly set"
	prefix = itemPrefix = label = ''
	if hOptions?
		if isString(hOptions)
			label = hOptions
		else
			assert isHash(hOptions), "log(): 2nd arg must be a string or hash"
			if hOptions.prefix?
				prefix = hOptions.prefix
			if hOptions.itemPrefix?
				itemPrefix = hOptions.itemPrefix
			else
				itemPrefix = prefix
			if hOptions.label?
				label = hOptions.label

	if isString(item) && (label == '')
		if hOptions? && hOptions.escape
			logger "#{prefix}#{escapeStr(item)}"
		else
			logger "#{prefix}#{item}"
		return

	if (label == '')
		label = 'ITEM'

	if (item == undef)
		logger "#{prefix}#{label} = undef"
	else if isString(item)
		if (item.length <= maxOneLine)
			logger "#{prefix}#{label} = '#{escapeStr(item)}'"
		else
			logger "#{prefix}#{label}:"
			logger "#{itemPrefix}#{sep_eq}"
			for line in blockToArray(item)
				logger "#{itemPrefix}#{escapeStr(line)}"
			logger "#{itemPrefix}#{sep_eq}"
	else if isNumber(item)
		logger "#{prefix}#{label} = #{item}"
	else
		logger "#{prefix}#{label}:"
		for str in blockToArray(stringify(item, true))
			logger "#{itemPrefix}\t#{str}"
	return

# ---------------------------------------------------------------------------

if ! loaded
	setStringifier orderedStringify
	resetLogger()
loaded = true
