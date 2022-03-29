# debug_utils.coffee

import {
	assert, undef, error, croak, warn, isString, isFunction, isBoolean,
	oneline, escapeStr, isNumber, isArray, words,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {untabify} from '@jdeighan/coffee-utils/indent'
import {slurp} from '@jdeighan/coffee-utils/fs'
import {CallStack} from '@jdeighan/coffee-utils/stack'
import {
	log, LOG, setStringifier, orderedStringify,
	} from '@jdeighan/coffee-utils/log'
import {getPrefix, arrow, removeArrow} from '@jdeighan/coffee-utils/arrow'

debugLevel = 0   # controls amount of indentation - we ensure it's never < 0

# --- These are saved/restored on the call stack
export debugging = false

# --- By default, when entering a function, keep the debugging flag
#     as it was
shouldDebugFunc = (func) -> debugging

# --- By default, log everything when debugging flag is on
shouldLogString = (str) -> debugging

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
	shouldDebugFunc = (func) -> debugging
	shouldLogString = (str)  -> debugging
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
		shouldDebugFunc = (funcName) ->
			funcMatch(funcName, lFuncNames)
		if DEBUGDEBUG
			console.log "setDebugging FUNCS: #{lFuncNames.join(',')}"
	else if isFunction(funcDoDebug)
		shouldDebugFunc = funcDoDebug
		if DEBUGDEBUG
			console.log "setDebugging to custom func"
	else
		croak "setDebugging(): bad parameter #{oneline(funcDoDebug)}"

	if funcDoLog
		assert isFunction(funcDoLog), "setDebugging: arg 2 not a function"
		shouldLogString = funcDoLog
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

	return {debugging, shouldDebugFunc, shouldLogString}

# ---------------------------------------------------------------------------

setEnv = (hEnv) ->

	{debugging, shouldDebugFunc, shouldLogString} = hEnv
	return

# ---------------------------------------------------------------------------

export debug = (lArgs...) ->

	# --- We want to allow item to be undef. Therefore, we need to
	#     distinguish between 1 arg sent vs. 2+ args sent
	nArgs = lArgs.length
	if DEBUGDEBUG
		LOG "debug() called with #{nArgs} args"
	[label, item] = lArgs

	# --- We always need to manipulate the stack when we encounter
	#     either "enter X" or "return from X", so we can't short-circuit
	#     when debugging is off

	assert isString(label),
			"debug(): 1st arg #{oneline(label)} should be a string"

	# --- determine if we're entering or returning from a function
	entering = returning = false
	curFunc = undef
	if (lMatches = label.match(///^
			\s*
			enter
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///))
		entering = true
		curFunc = lMatches[1]
		stack.call(curFunc, curEnv())
		debugging = shouldDebugFunc(curFunc)
		if DEBUGDEBUG
			LOG "ENTER #{curFunc}, debugging = #{debugging}"
	else if (lMatches = label.match(///^
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
		if DEBUGDEBUG && hInfo
			LOG "RETURN FROM #{curFunc}, debugging = #{hInfo.debugging}"

	if shouldLogString(label)
		# --- set the prefix, i.e. indentation to use
		if returning
			if (debugLevel==0)
				prefix = arrow
			else
				prefix = getPrefix(debugLevel, true)   # with arrow
		else
			prefix = getPrefix(debugLevel, false)   # no arrow

		if (nArgs==1)
			log label, {prefix}
		else
			itemPrefix = removeArrow(prefix, false)
			log item, {
				label
				prefix
				itemPrefix
				}
	else if DEBUGDEBUG
		LOG "shouldLogString('#{label}') returned FALSE"

	# --- Adjust debug level & contents of hInfo
	if returning
		if debugLevel > 0
			debugLevel -= 1
		if hInfo
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

resetDebugging()
