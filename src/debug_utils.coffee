# debug_utils.coffee

import {
	assert, undef, error, croak, warn, isString, isFunction, isBoolean,
	OL, escapeStr, isNumber, isArray, words, pass,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {untabify} from '@jdeighan/coffee-utils/indent'
import {slurp} from '@jdeighan/coffee-utils/fs'
import {CallStack} from '@jdeighan/coffee-utils/stack'
import {
	log, logItem, LOG, setStringifier, orderedStringify,
	} from '@jdeighan/coffee-utils/log'

# --- These are saved/restored on the call stack
export debugging = false
shouldLogFunc   = (func) -> debugging
shouldLogString = (str) -> debugging

stack = new CallStack()
doDebugDebug = false

# ---------------------------------------------------------------------------

export debugDebug = (flag=true) ->

	doDebugDebug = flag
	if doDebugDebug
		LOG "doDebugDebug = #{flag}"
	return

# ---------------------------------------------------------------------------

resetDebugging = () ->

	debugging = false
	if doDebugDebug
		LOG "resetDebugging() - debugging = false"
	stack.reset()
	shouldLogFunc = (func) -> debugging
	shouldLogString = (str)  -> debugging
	return

# ---------------------------------------------------------------------------

export setDebugging = (funcDoDebug=undef, funcDoLog=undef) ->

	resetDebugging()
	if isBoolean(funcDoDebug)
		debugging = funcDoDebug
		if doDebugDebug
			LOG "setDebugging(): debugging = #{funcDoDebug}"
	else if isString(funcDoDebug)
		debugging = false
		lFuncNames = words(funcDoDebug)
		assert isArray(lFuncNames), "words('#{funcDoDebug}') returned non-array"
		shouldLogFunc = (funcName) ->
			funcMatch(funcName, lFuncNames)
		if doDebugDebug
			LOG "setDebugging FUNCS: #{lFuncNames.join(',')}, debugging = false"
	else if isFunction(funcDoDebug)
		shouldLogFunc = funcDoDebug
		if doDebugDebug
			LOG "setDebugging to custom func"
	else
		croak "setDebugging(): bad parameter #{OL(funcDoDebug)}"

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
# 1. adjust call stack on 'enter' or 'return from'
# 2. adjust debugging flag
# 3. return [mainPrefix, auxPrefix, hEnv] - hEnv can be undef
# 4. disable logging by setting mainPrefix to undef

adjustStack = (str) ->

	if (lMatches = str.match(///^
			\s*
			enter
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///))
		curFunc = lMatches[1]
		hEnv = {
			debugging
			shouldLogFunc
			shouldLogString
			}
		debugging = shouldLogFunc(curFunc)
		if doDebugDebug
			trans = "#{hEnv.debugging} => #{debugging}"
			LOG "   ENTER #{curFunc}, debugging: #{trans}"
		[mainPre, auxPre, _] = stack.call(curFunc, hEnv, debugging)
		return [
			mainPre
			auxPre
			undef
			if shouldLogFunc(curFunc) then 'enter' else undef
			]
	else if (lMatches = str.match(///^
			\s*
			return
			.+
			from
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///))
		curFunc = lMatches[1]
		[mainPre, auxPre, hEnv] = stack.returnFrom(curFunc)
		if doDebugDebug
			LOG "   RETURN FROM #{curFunc}"
		return [
			mainPre
			auxPre
			hEnv
			if shouldLogFunc(curFunc) then 'return' else undef
			]
	else
		[mainPre, auxPre, _] = stack.logStr()
		return [
			mainPre
			auxPre
			undef
			if shouldLogString(str) then 'string' else undef
			]

# ---------------------------------------------------------------------------

export debug = (lArgs...) ->

	# --- We want to allow item to be undef. Therefore, we need to
	#     distinguish between 1 arg sent vs. 2 args sent
	nArgs = lArgs.length
	assert (nArgs==1) || (nArgs==2), "debug(): #{nArgs} args"
	[label, item] = lArgs
	assert isString(label),
			"debug(): 1st arg #{OL(label)} should be a string"

	if doDebugDebug
		if nArgs==1
			LOG "debug('#{escapeStr(label)}') - 1 arg"
		else
			LOG "debug('#{escapeStr(label)}', #{typeof item}) - 2 args"

	# --- We always need to manipulate the stack when we encounter
	#     either "enter X" or "return from X", so we can't short-circuit
	#     when debugging is off

	lResult = adjustStack(label)
	if doDebugDebug
		LOG 'lResult', lResult
	[mainPre, auxPre, hEnv, type] = lResult
	if doDebugDebug && (type == undef)
		LOG "type is undef - NOT LOGGING"

	hOptions = {
		prefix: mainPre
		itemPrefix: auxPre
		}

	switch type
		when 'enter'
			log label, hOptions
			if (nArgs==2)
				# --- don't repeat the label
				logItem undef, item, hOptions
		when 'return'
			log label, hOptions
			if (nArgs==2)
				# --- don't repeat the label
				logItem undef, item, hOptions
		when 'string'
			if (nArgs==2)
				logItem label, item, hOptions
			else
				log label, hOptions

	if hEnv
		orgDebugging = debugging
		{debugging, shouldLogFunc, shouldLogString} = hEnv
		if doDebugDebug
			trans = "#{orgDebugging} => #{debugging}"
			LOG "   Restore hEnv: debugging: #{trans}"
	return true   # allow use in boolean expressions

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
