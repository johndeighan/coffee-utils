# log_utils.coffee

import yaml from 'js-yaml'

import {
	assert, undef, isNumber, isInteger, isString, isHash, isFunction,
	escapeStr, sep_eq, sep_dash
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {tabify, untabify, indentation} from '@jdeighan/coffee-utils/indent'
import {arrow, hasArrow, removeArrow} from '@jdeighan/coffee-utils/arrow'

# --- This logger only ever gets passed a single string argument
putstr = undef

export stringify = undef
objSep = '-'.repeat(42)

# ---------------------------------------------------------------------------
# This is useful for debugging and easy to remove after debugging

export LOG = (lArgs...) ->

	[label, item] = lArgs
	if lArgs.length > 1
		console.log objSep
		if item?
			console.log "#{label}:"
			console.log untabify(orderedStringify(item))
		else
			console.log "[#{label}]: UNDEFINED"
		console.log objSep
	else
		console.log label
	return

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
		lineWidth: -1
		replacer: if escape then escReplacer else (name,value) -> value
		})

	return "---\n" + tabify(str, 1)

# ---------------------------------------------------------------------------

maxOneLine = 32

# ---------------------------------------------------------------------------

export log = (item, hOptions={}) ->
	# --- valid options:
	#   label
	#   prefix
	#   itemPrefix
	#   escape

	assert isFunction(putstr), "putstr not properly set"
	if isString(hOptions)
		label = hOptions
		prefix = itemPrefix = ''
	else
		assert isHash(hOptions), "log(): 2nd arg must be a string or hash"
		label = hOptions.label || ''
		prefix = hOptions.prefix ||  ''
		itemPrefix = hOptions.itemPrefix || prefix || ''

	# --- If putstr is console.log, we'll convert TAB char to 3 spaces
	if putstr == console.log
		label = untabify(label)
		prefix = untabify(prefix)
		itemPrefix = untabify(itemPrefix)

	if isString(item) && (label == '')
		if hOptions.escape
			putstr "#{prefix}#{escapeStr(item)}"
		else
			putstr "#{prefix}#{item}"
		return

	if (label == '')
		label = 'ITEM'

	if (item == undef)
		putstr "#{prefix}#{label} = undef"
	else if isString(item)
		if (item.length <= maxOneLine)
			putstr "#{prefix}#{label} = '#{escapeStr(item)}'"
		else
			putstr "#{prefix}#{label}:"
			putstr "#{itemPrefix}#{sep_eq}"
			for line in blockToArray(item)
				putstr "#{itemPrefix}#{escapeStr(line)}"
			putstr "#{itemPrefix}#{sep_eq}"
	else if isNumber(item)
		putstr "#{prefix}#{label} = #{item}"
	else
		putstr "#{removeArrow(prefix, true)}#{objSep}"
		putstr "#{prefix}#{label}:"
		for str in blockToArray(stringify(item, true))
			if putstr == console.log
				putstr "#{itemPrefix}   #{untabify(str)}"
			else
				putstr "#{itemPrefix}#{indentation(1)}#{str}"
		putstr "#{removeArrow(prefix, false)}#{objSep}"
	return

# ---------------------------------------------------------------------------

if ! loaded
	setStringifier orderedStringify
	resetLogger()
loaded = true
