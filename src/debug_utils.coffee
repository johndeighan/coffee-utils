# debug_utils.coffee

import {
	undef,
	say,
	error,
	isString,
	stringToArray,
	tamlStringify,
	setLogger,
	escapeStr,
	} from '@jdeighan/coffee-utils'
import {
	indentedStr,
	indentedBlock,
	} from '@jdeighan/coffee-utils/indent'

vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

indent = vbar + '   '
arrow = corner + hbar + arrowhead + ' '

debugLevel = 0           # controls amount of indentation
export debugging = false
stringifier = tamlStringify

# ---------------------------------------------------------------------------

export setStringifier = (func) ->

	stringifier = func
	return

# ---------------------------------------------------------------------------

export setDebugging = (flag, loggerFunc=undef, dumperFunc=undef) ->

	debugging = flag
	debugLevel = 0
	if flag && loggerFunc && dumperFunc
		setLogger loggerFunc, dumperFunc
	return

# ---------------------------------------------------------------------------

export debug = (item, label=undef) ->

	if not debugging
		return

	# --- determine if we're entering or returning from a function
	enter = exit = false
	if label
		if not isString(label)
			error "debug(): label must be a string"
		enter = (label.indexOf('enter') == 0)
		exit =  (label.indexOf('return') == 0)
	else
		if not isString(item)
			error "debug(): single parameter must be a string"
		enter = (item.indexOf('enter') == 0)
		exit =  (item.indexOf('return') == 0)

	if exit
		prefix = indent.repeat(debugLevel-1) + arrow
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
			say prefix + '   ' + str.replace(/\t/g, '   ')

	if enter
		debugLevel += 1
	if exit && (debugLevel > 0)
		debugLevel -= 1
	return
