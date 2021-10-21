# debug_utils.coffee

import {
	assert, undef, error, croak, warn, words, isString, isFunction,
	oneline, escapeStr, isNumber, isArray,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {log} from '@jdeighan/coffee-utils/log'
import {slurp} from '@jdeighan/coffee-utils/fs'

vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

indent = vbar + '   '
arrow = corner + hbar + arrowhead + ' '

debugLevel = 0   # controls amount of indentation - we ensure it's never < 0

lDebugStack = []

# --- These are saved/restored in lDebugStack
export debugging = false
ifMatches = undef
lDebugFuncs = undef

# ---------------------------------------------------------------------------

stripArrow = (prefix) ->

	return prefix.replace(arrow, '    ')

# ---------------------------------------------------------------------------

export debugIfLineMatches = (regexp=undef) ->

	ifMatches = regexp
	return

# ---------------------------------------------------------------------------

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

export resetDebugging = () ->

	debugging = false
	debugLevel = 0
	ifMatches = undef
	lDebugFuncs = undef
	lDebugStack = []
	return

# ---------------------------------------------------------------------------

export debug = (lArgs...) ->
	# --- either 1 or 2 args

	# --- We always need to manipulate the stack when we encounter
	#     either "enter X" or "return from X", so we can't short-circuit
	#     when debugging is off

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
	entering = returning = false
	curFunc = undef
	if (lMatches = str.match(///^
			\s*
			enter
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///))
		entering = true
		curFunc = lMatches[1]
	else if (lMatches = str.match(///^
			\s*
			return
			.*
			from
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///))
		returning = true
		curFunc = lMatches[1]

	if entering && lDebugFuncs && funcMatch(curFunc)
		setDebugging true

	if debugging && (! ifMatches? || str.match(ifMatches))

		# --- set the prefix, i.e. indentation to use
		if returning
			if (debugLevel==0)
				prefix = arrow
			else
				prefix = indent.repeat(debugLevel-1) + arrow
		else
			prefix = indent.repeat(debugLevel)

		if (nArgs==1)
			log str, item, {prefix}
		else
			log str, item, {
				prefix,
				logItem: true,
				itemPrefix: stripArrow(prefix),
				}
		if returning && (debugLevel > 0)
			debugLevel -= 1

	if returning && lDebugFuncs && funcMatch(curFunc)
		setDebugging false    # revert to previous setting - might still be on

	if debugging && entering
		debugLevel += 1
	return

# ---------------------------------------------------------------------------

reMethod = ///^
	([A-Za-z_][A-Za-z0-9_]*)
	\.
	([A-Za-z_][A-Za-z0-9_]*)
	$///

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export funcMatch = (curFunc) ->

	if lDebugFuncs.includes(curFunc)
		return true
	else if (lMatches = curFunc.match(reMethod)) \
			&& ([_, cls, meth] = lMatches) \
			&& lDebugFuncs.includes(meth)
		return true
	else
		return false

# ---------------------------------------------------------------------------

export checkTrace = (block) ->
	# --- export only to allow unit tests

	lStack = []

	for line in blockToArray(block)
		if lMatches = line.match(///
				enter
				\s+
				([A-Za-z_][A-Za-z0-9_\.]*)
				///)
			funcName = lMatches[1]
			lStack.push funcName
		else if lMatches = line.match(///
				return
				.*
				from
				\s+
				([A-Za-z_][A-Za-z0-9_\.]*)
				///)
			funcName = lMatches[1]
			len = lStack.length
			if (len == 0)
				log "return from #{funcName} with empty stack"
			else if (lStack[len-1] == funcName)
				lStack.pop()
			else if (lStack[len-2] == funcName)
				log "missing return from #{lStack[len-2]}"
				lStack.pop()
				lStack.pop()
			else
				log "return from #{funcName} - not found on stack"
	return

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export checkTraceFile = (filepath) ->

	checkTrace(slurp(filepath))
	return
