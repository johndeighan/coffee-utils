# debug_utils.coffee

import {
	undef, say, pass, error, isString, stringToArray,
	tamlStringify, setLogger, escapeStr,
	} from '@jdeighan/coffee-utils'

vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

indent = vbar + '   '
arrow = corner + hbar + arrowhead + ' '

debugLevel = 0           # controls amount of indentation
export debugging = false
stringifier = tamlStringify

ifMatches = undef

# ---------------------------------------------------------------------------

export setStringifier = (func) ->

	stringifier = func
	return

# ---------------------------------------------------------------------------

export setDebugging = (flag, hOptions={}) ->

	debugging = flag
	debugLevel = 0
	if flag
		{loggerFunc, dumperFunc, ifMatches: regexp} = hOptions
		if loggerFunc && dumperFunc
			setLogger loggerFunc, dumperFunc
		if regexp
			ifMatches = regexp
	else
		ifMatches = undef
	return

# ---------------------------------------------------------------------------

export debug = (item, label=undef) ->

	if not debugging
		return

	toTest = label || item
	if isString(toTest) && ifMatches? && not toTest.match(ifMatches)
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
