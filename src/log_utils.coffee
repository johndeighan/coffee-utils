# log_utils.coffee

import yaml from 'js-yaml'

import {assert, error, croak} from '@jdeighan/unit-tester/utils'
import {
	undef, isNumber, isInteger, isString, isHash, isFunction,
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

export LOGLINES = (label, lLines) ->

	LOG "#{label}:"
	for line in lLines
		LOG "#{OL(line)}"
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
	return "---\n" + str

# ---------------------------------------------------------------------------

export orderedStringify = (obj, escape=false) ->

	str = yaml.dump(obj, {
		skipInvalid: true
		indent: 1
		sortKeys: true
		lineWidth: 40
		replacer: if escape then escReplacer else (name,value) -> value
		})

	return "---\n" + str

# ---------------------------------------------------------------------------

maxOneLine = 32

# ---------------------------------------------------------------------------

export log = (str, prefix='') ->

	assert isString(prefix), "not a string: #{OL(prefix)}"
	assert isString(str),      "log(): not a string: #{OL(str)}"
	assert isFunction(putstr), "putstr not properly set"
	prefix = fixForTerminal(prefix)

	if doDebugLog
		LOG "CALL log(#{OL(str)}), prefix = #{OL(prefix)}"

	putstr "#{prefix}#{str}"
	return true   # to allow use in boolean expressions

# ---------------------------------------------------------------------------

export logBareItem = (item, pre='') ->

	logItem undef, item, pre
	return

# ---------------------------------------------------------------------------

export logItem = (label, item, pre='', itemPre=undef) ->

	assert isString(pre), "not a string: #{OL(pre)}"
	assert isFunction(putstr), "putstr not properly set"
	assert !label || isString(label), "label a non-string"
	if (itemPre == undef)
		itemPre = pre

	assert pre.indexOf("\t") == -1, "pre has TAB"
	assert itemPre.indexOf("\t") == -1, "itemPre has TAB"

	if doDebugLog
		LOG "CALL logItem(#{OL(label)}, #{OL(item)})"
		LOG "pre = #{OL(pre)}"
		LOG "itemPre = #{OL(itemPre)}"

	labelStr = if label then "#{label} = " else ""

	if (item == undef)
		putstr "#{pre}#{labelStr}undef"
	else if (item == null)
		putstr "#{pre}#{labelStr}null"
	else if isNumber(item)
		putstr "#{pre}#{labelStr}#{item}"
	else if isString(item)
		if (item.length <= maxOneLine)
			putstr "#{pre}#{labelStr}'#{escapeStr(item)}'"
		else
			if label
				putstr "#{pre}#{label}:"
			putBlock item, itemPre
	else
		if label
			putstr "#{pre}#{label}:"

		# --- escape special chars
		for str in blockToArray(stringify(item, true))
			putstr "#{itemPre}#{str}"

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
