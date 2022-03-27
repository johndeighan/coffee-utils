# debug_utils.coffee

import {
	assert, error, croak, warn, isString, isFunction, isBoolean,
	oneline, escapeStr, isNumber, isArray, words,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {untabify} from '@jdeighan/coffee-utils/indent'
import {slurp} from '@jdeighan/coffee-utils/fs'
import {CallStack} from '@jdeighan/coffee-utils/stack'
import {
	log, setStringifier, orderedStringify,
	} from '@jdeighan/coffee-utils/log'

undef = undefined
vbar = '│'       # unicode 2502
hbar = '─'       # unicode 2500
corner = '└'     # unicode 2514
arrowhead = '>'

indent = vbar + '   '
arrow = corner + hbar + arrowhead + ' '

debugLevel = 0   # controls amount of indentation - we ensure it's never < 0

# --- These are saved/restored on the call stack
export debugging = false
shouldDebug = shouldLog = undef

stack = new CallStack()
DEBUGDEBUG = false

# ---------------------------------------------------------------------------

export setDEBUGDEBUG = (flag=true) ->

	DEBUGDEBUG = flag
	console.log "DEBUGDEBUG = #{flag}"
	return

# ---------------------------------------------------------------------------

export resetDebugging = (funcDoDebug=undef, funcDoLog=undef) ->

	debugging = false
	debugLevel = 0
	stack.reset()
	shouldDebug = (funcName) -> debugging
	shouldLog   = (str) -> debugging
	if funcDoDebug
		setDebugging funcDoDebug, funcDoLog
	return

# ---------------------------------------------------------------------------

export setDebugging = (funcDoDebug=undef, funcDoLog=undef) ->

	if isBoolean(funcDoDebug)
		if DEBUGDEBUG
			console.log "setDebugging #{funcDoDebug}"
		debugging = funcDoDebug
	else if isString(funcDoDebug)
		debugging = false
		lFuncNames = words(funcDoDebug)
		assert isArray(lFuncNames), "words('#{funcDoDebug}') returned non-array"
		shouldDebug = (funcName) ->
			funcMatch(funcName, lFuncNames)
		if DEBUGDEBUG
			console.log "setDebugging FUNCS: #{lFuncNames.join(',')}"
	else if isFunction(funcDoDebug)
		shouldDebug = funcDoDebug
		if DEBUGDEBUG
			console.log "setDebugging to custom func"
	else
		croak "setDebugging(): bad parameter #{oneline(funcDoDebug)}"

	if funcDoLog
		assert isFunction(funcDoLog), "setDebugging: arg 2 not a function"
		shouldLog = funcDoLog
	return

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export funcMatch = (curFunc, lFuncNames) ->

	assert isString(curFunc), "funcMatch(): not a string"
	assert isArray(lFuncNames), "funcMatch(): bad array #{lFuncNames}"
	if lFuncNames.includes(curFunc)
		return true
	else if (lMatches = curFunc.match(reMethod)) \
			&& ([_, cls, meth] = lMatches) \
			&& lFuncNames.includes(meth)
		return true
	else
		return false

# ---------------------------------------------------------------------------

curEnv = () ->

	return {debugging, shouldDebug, shouldLog}

# ---------------------------------------------------------------------------

setEnv = (hEnv) ->

	{debugging, shouldDebug, shouldLog} = hEnv
	return

# ---------------------------------------------------------------------------
# --- 2 possible signatures:
#        (item) - just log out the string
#        (item, hOptions) - log out the object, with a label

logger = (item, hOptions=undef) ->

	log item, hOptions
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

	# --- We always need to manipulate the stack when we encounter
	#     either "enter X" or "return from X", so we can't short-circuit
	#     when debugging is off

	nArgs = lArgs.length
	assert ((nArgs == 1) || (nArgs == 2)), "debug(); Bad # args #{nArgs}"
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
		stack.call(curFunc, curEnv())
		debugging = shouldDebug(curFunc)
	else if (lMatches = str.match(///^
			\s*
			return
			.+
			from
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///))
		returning = true
		curFunc = lMatches[1]
		hInfo = stack.returnFrom(curFunc)

	if shouldLog(str)

		# --- set the prefix, i.e. indentation to use
		if returning
			if (debugLevel==0)
				prefix = arrow
			else
				prefix = indent.repeat(debugLevel-1) + arrow
		else
			prefix = indent.repeat(debugLevel)

		if (nArgs==1)
			logger str, {
				prefix: prefix
				}
		else
			itemPrefix = prefix.replace(arrow, '    ')
			logger item, {
				label: str
				prefix: prefix
				itemPrefix
				}

	# --- Adjust debug level
	if returning
		if debugLevel > 0
			debugLevel -= 1
		setEnv(hInfo)
	else if entering
		if debugging
			debugLevel += 1
	return

# ---------------------------------------------------------------------------

reMethod = ///^
	([A-Za-z_][A-Za-z0-9_]*)
	\.
	([A-Za-z_][A-Za-z0-9_]*)
	$///

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
				logger "return from #{funcName} with empty stack"
			else if (lStack[len-1] == funcName)
				lStack.pop()
			else if (lStack[len-2] == funcName)
				logger "missing return from #{lStack[len-2]}"
				lStack.pop()
				lStack.pop()
			else
				logger "return from #{funcName} - not found on stack"
	return

# ---------------------------------------------------------------------------

resetDebugging()
