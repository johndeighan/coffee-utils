# debug_utils.coffee

import {strict as assert} from 'assert'
import {
	undef, log, error, warn, isString, isFunction,
	stringToArray, oneline, currentLogger, currentStringifier,
	setLogger, setStringifier, stringify, escapeStr,
	} from '@jdeighan/coffee-utils'

vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

indent = vbar + '   '
arrow = corner + hbar + arrowhead + ' '

debugLevel = 0   # controls amount of indentation - we ensure it's never < 0

# --- items on lDebugStack are hashes:
#        debugging: <boolean>
#        ifMatches: <regexp> or undef
#        logger: <function> or undef
#        stringifier: <function> or undef

lDebugStack = []
export debugging = false

ifMatches = undefined

# ---------------------------------------------------------------------------

export startDebugging = (hOptions={}) ->
	# --- Valid options:
	#        debuggingOff - if set, temporarily turns debugging off
	#        ifMatches - set ifMatches
	#        logger - set the function for logging
	#        stringifier - set the function for stringifying

	# --- save current settings
	lDebugStack.push({
		debugging,
		ifMatches,
		logger: currentLogger(),
		stringifier: currentStringifier(),
		})

	# --- set current settings from hOptions
	if hOptions.debuggingOff
		debugging = false
	else
		debugging = true
	ifMatches = hOptions.ifMatches
	if hOptions.logger
		assert isFunction(hOptions.logger),
			"startDebugging() logger not a function"
		setLogger hOptions.logger
	if hOptions.stringifier && isFunction(hOptions.stringifier)
		assert isFunction(hOptions.stringifier),
			"startDebugging() stringifier not a function"
		setStringifier hOptions.stringifier

# ---------------------------------------------------------------------------

export endDebugging = () ->

	assert (lDebugStack.length > 0), "endDebugging(): empty stack"
	hInfo = lDebugStack.pop()
	debugging = hInfo.debugging
	ifMatches = hInfo.ifMatches
	setLogger hInfo.logger
	setStringifier hInfo.stringifier
	return

# ---------------------------------------------------------------------------

getPrefix = (level) ->

	if (level < 0)
		warn "You have mismatched debug 'enter'/'return' somewhere!"
		return ''
	return '   '.repeat(level)

# ---------------------------------------------------------------------------

export debug = (item, label=undef) ->

	if not debugging
		return

	if ifMatches?
		toTest = label || item
		if isString(toTest) && not toTest.match(ifMatches)
			return

	# --- if item is 'tree', just print label && increment debugLevel
	#     if item is 'untree', print nothing && decrement debugLevel
	if (item == 'tree')
		log getPrefix(debugLevel) + label
		debugLevel += 1
		return
	else if (item == 'untree') && (debugLevel > 0)
		debugLevel -= 1
		return

	# --- determine if we're entering or returning from a function
	entering = exiting = false
	if label
		assert isString(label), "debug(): label must be a string"
		entering = (label.indexOf('enter') == 0)
		exiting =  (label.indexOf('return') == 0)
	else
		assert isString(item), "debug(): single parameter must be a string"
		entering = (item.indexOf('enter') == 0)
		exiting =  (item.indexOf('return') == 0)

	if exiting
		n = if (debugLevel==0) then 0 else debugLevel-1
		prefix = indent.repeat(n) + arrow
	else
		prefix = indent.repeat(debugLevel)

	if not item?
		if label
			log prefix +  label + " undef"
		else
			log prefix + " undef"
	else if isString(item)
		if item.match(/\n/)    # it's a multi-line string
			if label
				log prefix + label
			for line in stringToArray(item)
				log prefix + escapeStr(line)
		else if label
			log prefix +  label + " " + escapeStr(item)
		else
			log prefix + escapeStr(item)
	else
		if label
			log prefix + label
		for str in stringToArray(stringify(item))
			# --- We're exiting, but we want the normal prefix
			prefix = indent.repeat(debugLevel)
			log prefix + '   ' + str.replace(/\t/g, '   ')

	if entering
		debugLevel += 1
	if exiting && (debugLevel > 0)
		debugLevel -= 1
	return
