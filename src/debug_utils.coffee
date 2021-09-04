# debug_utils.coffee

import {
	undef, say, pass, error, isString, stringToArray,
	setLogger, setStringifier, escapeStr, stringifier, tamlStringifier,
	} from '@jdeighan/coffee-utils'

vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

indent = vbar + '   '
arrow = corner + hbar + arrowhead + ' '

debugLevel = 0           # controls amount of indentation

# --- Settings for variable debugging:
#        undef   = debugging turned off
#        true    = debugging turned on
#        'force' = debugging always on, log calls to setDebugging()

export debugging = false

ifMatches = undefined

# ---------------------------------------------------------------------------

export setDebugging = (flag, hOptions={}) ->
	# --- Valid options:
	#        loggerFunc - set the function for logging
	#        stringifierFunc - set the function for stringifying
	#        regexp - set ifMatches
	#        force - turn on permanently

	debugging = flag
	debugLevel = 0
	if flag
		{loggerFunc, stringifierFunc, ifMatches: regexp} = hOptions
		if loggerFunc
			setLogger loggerFunc
		else
			setLogger console.log
		if stringifierFunc
			setStringifier stringifierFunc
		else
			setStringifier tamlStringifier
		if regexp
			ifMatches = regexp
		else
			ifMatches = undef
	else
		ifMatches = undef
	return

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
		say '   '.repeat(debugLevel) + label
		debugLevel += 1
		return
	else if (item == 'untree')
		debugLevel -= 1
		return

	# --- determine if we're entering or returning from a function
	entering = exiting = false
	if label
		if not isString(label)
			error "debug(): label must be a string"
		entering = (label.indexOf('enter') == 0)
		exiting =  (label.indexOf('return') == 0)
	else
		if not isString(item)
			error "debug(): single parameter must be a string"
		entering = (item.indexOf('enter') == 0)
		exiting =  (item.indexOf('return') == 0)

	if exiting
		n = if (debugLevel==0) then 0 else debugLevel-1
		prefix = indent.repeat(n) + arrow
	else
		prefix = indent.repeat(debugLevel)

	if not item?
		if label
			say prefix +  label + " undef"
		else
			say prefix + " undef"
	else if isString(item)
		if label
			say prefix +  label + " '" + escapeStr(item) + "'"
		else
			say prefix + escapeStr(item)
	else
		if label
			say prefix + label
		for str in stringToArray(stringifier(item))
			# --- We're exiting, but we want the normal prefix
			prefix = indent.repeat(debugLevel)
			say prefix + '   ' + str.replace(/\t/g, '   ')

	if entering
		debugLevel += 1
	if exiting && (debugLevel > 0)
		debugLevel -= 1
	return
