# debug_utils.coffee

import {strict as assert} from 'assert'
import {
	undef, error, croak, warn, words, isString, isFunction,
	stringToArray, oneline, escapeStr, isNumber, isArray,
	} from '@jdeighan/coffee-utils'
import {log} from '@jdeighan/coffee-utils/log'

vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

indent = vbar + '   '
arrow = corner + hbar + arrowhead + ' '

debugLevel = 0   # controls amount of indentation - we ensure it's never < 0

# --- These are saved/restored in lDebugStack
export debugging = false
ifMatches = undefined
lDebugFuncs = undefined

# ---------------------------------------------------------------------------

export debugIfLineMatches = (regexp=undef) ->

	ifMatches = regexp
	return

# ---------------------------------------------------------------------------

lDebugStack = []

saveDebugEnv = () ->

	lDebugStack.push({
		debugging,
		ifMatches,
		lDebugFuncs,
		})
	return

restoreDebugEnv = () ->

	if (lDebugStack.length == 0)
		debugging = false
		ifMatches = undef
		lDebugFuncs = undef
	else
		h = lDebugStack.pop()
		{debugging, ifMatches, lDebugFuncs} = h

	return

# ---------------------------------------------------------------------------

export setDebugging = (x) ->

	if (x==false)
		restoreDebugEnv()
	else
		# --- save current setting
		saveDebugEnv()
		if (x==true)
			debugging = true
		else if isString(x)
			debugging = false
			lDebugFuncs = words(x)
		else
			croak "setDebugging(): bad parameter #{oneline(x)}"
	return

# ---------------------------------------------------------------------------

getPrefix = (level) ->

	if (level < 0)
		warn "You have mismatched debug 'enter'/'return' somewhere!"
		return ''
	return '   '.repeat(level)

# ---------------------------------------------------------------------------

export debug = (lArgs...) ->
	# --- either 1 or 2 args

	if not debugging && not lDebugFuncs?
		return

	nArgs = lArgs.length
	assert ((nArgs >= 1) && (nArgs <= 2)), "debug(); Bad # args #{nArgs}"
	str = lArgs[0]

	# --- str must always be a string
	#     if 2 args, then str is meant to be a label for the item

	assert isString(str),
			"debug(): 1st arg #{oneline(str)} should be a string"

	if (nArgs==2)
		item = lArgs[1]

	# --- determine if we're entering or returning from a function
	entering = exiting = false
	curFunction = undef
	if (lMatches = str.match(///^
			\s*
			enter
			\s+
			([A-Za-z_][A-Za-z0-9_]*)
			///))
		entering = true
		curFunction = lMatches[1]
	else if (lMatches = str.match(///^
			\s*
			return
			.*
			from
			\s+
			([A-Za-z_][A-Za-z0-9_]*)
			///))
		exiting = true
		curFunction = lMatches[1]

	if entering && lDebugFuncs && lDebugFuncs.includes(curFunction)
		setDebugging true

	if not debugging
		return

	if not ifMatches? || str.match(ifMatches)

		# --- set the prefix, i.e. indentation to use
		if exiting
			if (debugLevel==0)
				prefix = arrow
			else
				prefix = indent.repeat(debugLevel-1) + arrow
		else
			prefix = indent.repeat(debugLevel)

		if (nArgs==1)
			log str, item, {prefix}
		else
			log str, item, {prefix, logItem: true}

	if exiting && lDebugFuncs && lDebugFuncs.includes(curFunction)
		setDebugging false # revert to previous setting - might still be on
		return

	if entering
		debugLevel += 1
	if exiting && (debugLevel > 0)
		debugLevel -= 1
	return
