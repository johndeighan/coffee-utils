# debug_utils.coffee

import {
	assert, undef, error, croak, warn, defined,
	isString, isFunction, isBoolean, sep_dash,
	OL, escapeStr, isNumber, isArray, words, pass,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {untabify} from '@jdeighan/coffee-utils/indent'
import {slurp} from '@jdeighan/coffee-utils/fs'
import {CallStack} from '@jdeighan/coffee-utils/stack'
import {
	getPrefix, addArrow, removeLastVbar,
	} from '@jdeighan/coffee-utils/arrow'
import {
	log, logItem, LOG, shortEnough,
	} from '@jdeighan/coffee-utils/log'

callStack = new CallStack()
doDebugDebug = false
shouldLog = undef     # set in resetDebugging() and setDebugging()

# ---------------------------------------------------------------------------

export debugDebug = (flag=true) ->

	doDebugDebug = flag
	if doDebugDebug
		LOG "doDebugDebug = #{flag}"
	return

# ---------------------------------------------------------------------------

resetDebugging = () ->

	if doDebugDebug
		LOG "resetDebugging()"
	callStack.reset()
	shouldLog = (type, str, stack) -> false
	return

# ---------------------------------------------------------------------------

export setDebugging = (option) ->

	resetDebugging()
	if isBoolean(option)
		shouldLog = (type, str, stack) -> option
	else if isString(option)
		shouldLog = (type, str, stack) ->
			lFuncs = words(option)
			switch type
				when 'enter'
					return funcMatch(stack, lFuncs, str)
				else
					return funcMatch(stack, lFuncs)
		if doDebugDebug
			LOG "setDebugging FUNCS: #{option}"
	else if isFunction(option)
		shouldLog = option
		if doDebugDebug
			LOG "setDebugging to custom func"
	else
		croak "setDebugging(): bad parameter #{OL(option)}"
	return

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export funcMatch = (stack, lFuncNames, enteringFunc=undef) ->

	if defined(enteringFunc) && (enteringFunc in lFuncNames)
		return true

	curFunc = stack.curFunc()
	assert isString(curFunc), "funcMatch(): not a string #{OL(curFunc)}"
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
# --- type is one of: 'enter', 'return', 'string', 'object'

export getType = (str, nObjects) ->

	if lMatches = str.match(///^
			\s*
			enter
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///)

		# --- We are entering function curFunc
		return ['enter', lMatches[1]]

	else if lMatches = str.match(///^
			\s*
			return
			.+
			from
			\s+
			([A-Za-z_][A-Za-z0-9_\.]*)
			///)
		return ['return', lMatches[1]]

	else if (nObjects > 0)
		return ['objects', undef]
	else
		return ['string', undef]

# ---------------------------------------------------------------------------

export debug = (label, lObjects...) ->

	assert isString(label), "1st arg #{OL(label)} should be a string"

	# --- We want to allow objects to be undef. Therefore, we need to
	#     distinguish between 1 arg sent vs. 2 or more args sent
	nObjects = lObjects.length

	# --- funcName is only set for types 'enter' and 'return'
	[type, funcName] = getType(label, nObjects)
	switch type
		when 'enter'
			doLog = shouldLog(type, funcName, callStack)

			# --- If we won't be logging when funcName is activated
			#     then change 'enter' to 'call'
			callStack.enter funcName       # add to call stack
			if ! shouldLog('string', 'abc', callStack)
				label = label.replace('enter', 'call')
			callStack.returnFrom funcName  # remove from call stack
		when 'return'
			doLog = shouldLog(type, funcName, callStack)
		when 'string'
			doLog = shouldLog(type, label, callStack)
			assert (nObjects == 0),
					"multiple objects only not allowed for #{OL(type)}"
		when 'objects'
			doLog = shouldLog(type, label, callStack)
			assert (nObjects > 0),
					"multiple objects only not allowed for #{OL(type)}"

	if doDebugDebug
		if nObjects == 0
			LOG "debug(#{OL(label)}) - 1 arg"
		else
			LOG "debug(#{OL(label)}), #{nObjects} args"
		LOG "doLog = #{OL(doLog)}"
		LOG "type = #{OL(type)}"
		LOG "funcName = #{OL(funcName)}"

	if doLog
		level = callStack.getLevel()
		prefix = getPrefix(level)

		if doDebugDebug
			LOG "callStack", callStack
			LOG "level = #{OL(level)}"
			LOG "prefix = #{OL(prefix)}"

		switch type
			when 'enter'
				log label, {prefix}
				for obj,i in lObjects
					if (i > 0)
						log sep_dash, {prefix: removeLastVbar(prefix)}
					logItem undef, obj, {prefix: removeLastVbar(prefix)}
			when 'return'
				log label, {prefix: addArrow(prefix)}
				for obj,i in lObjects
					if (i > 0)
						log sep_dash, {prefix: removeLastVbar(prefix)}
					logItem undef, obj, {prefix: removeLastVbar(prefix)}
			when 'string'
				log label, {prefix}
			when 'objects'
				if (nObjects==1) && shortEnough(label, lObjects[0])
					logItem label, lObjects[0], {prefix}
				else
					if (label.indexOf(':') != label.length - 1)
						label += ':'
					log label, {prefix}
					for obj in lObjects
						logItem undef, obj, {prefix}

	if (type == 'enter')
		callStack.enter funcName, doLog
	else if (type == 'return')
		callStack.returnFrom funcName

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
