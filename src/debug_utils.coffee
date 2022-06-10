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

export shouldLog = undef  # set in resetDebugging() and setDebugging()
export lFuncList = []

# ---------------------------------------------------------------------------

export debug = (label, lObjects...) ->

	assert isString(label), "1st arg #{OL(label)} should be a string"

	# --- We want to allow objects to be undef. Therefore, we need to
	#     distinguish between 1 arg sent vs. 2 or more args sent
	nObjects = lObjects.length

	# --- funcName is only set for types 'enter' and 'return'
	[type, funcName] = getType(label, nObjects)
	if doDebugDebug
		LOG "debug(): type = #{OL(type)}"
		LOG "debug(): funcName = #{OL(funcName)}"

	switch type
		when 'enter'
			callStack.enter funcName
			label = shouldLog(label, type, funcName, callStack)
		when 'return'
			label = shouldLog(label, type, funcName, callStack)
		when 'string'
			label = shouldLog(label, type, undef, callStack)
			assert (nObjects == 0),
					"multiple objects only not allowed for #{OL(type)}"
		when 'objects'
			label = shouldLog(label, type, undef, callStack)
			assert (nObjects > 0),
					"multiple objects only not allowed for #{OL(type)}"
	doLog = defined(label)

	if doDebugDebug
		if nObjects == 0
			LOG "debug(#{OL(label)}) - 1 arg"
		else
			LOG "debug(#{OL(label)}), #{nObjects} args"
		LOG "doLog = #{OL(doLog)}"

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

	if (type == 'enter') && doLog && (label.indexOf('call') == -1)
		callStack.logCurFunc()
	else if (type == 'return')
		callStack.returnFrom funcName

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export stdShouldLog = (label, type, funcName, stack) ->
	# --- if type is 'enter', then funcName won't be on the stack yet
	#     returns the (possibly modified) label to log

	# --- If we're logging now,
	#     but we won't be logging when funcName is activated
	#     then change 'enter' to 'call'

	assert isString(label), "label #{OL(label)} not a string"
	assert isString(type),  "type #{OL(type)} not a string"
	if (type == 'enter') || (type == 'return')
		assert isString(funcName), "func name #{OL(funcName)} not a string"
	else
		assert funcName == undef, "func name #{OL(funcName)} not undef"
	assert stack instanceof CallStack, "not a call stack object"

	if doDebugDebug
		LOG "stdShouldLog(#{OL(label)}, #{OL(type)}, #{OL(funcName)}, stack)"
		LOG "stack", stack
		LOG "lFuncList", lFuncList

	switch type
		when 'enter'
			if funcMatch(stack, lFuncList)
				return label

			else
				# --- As a special case, if we enter a function where we will not
				#     be logging, but we were logging in the calling function,
				#     we'll log out the call itself

				prevLogged = stack.isLoggingPrev()
				if prevLogged
					return label.replace('enter', 'call')
		else
			if funcMatch(stack, lFuncList)
				return label
	return undef

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
	shouldLog = (label, type, funcName, stack) -> undef
	return

# ---------------------------------------------------------------------------

export setDebugging = (option) ->

	resetDebugging()
	if isBoolean(option)
		if option
			shouldLog = (label, type, funcName, stack) -> label
		else
			shouldLog = (label, type, funcName, stack) -> undef
		if doDebugDebug
			LOG "setDebugging = #{option}"
	else if isString(option)
		lFuncList = getFuncList(option)
		shouldLog = stdShouldLog
		if doDebugDebug
			LOG "setDebugging FUNCS: #{option}"
			LOG 'lFuncList', lFuncList
	else if isFunction(option)
		shouldLog = option
		if doDebugDebug
			LOG "setDebugging to custom func"
	else
		croak "bad parameter #{OL(option)}"
	return

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export getFuncList = (str) ->

	lFuncList = []
	for word in words(str)
		if lMatches = word.match(///^
				([A-Za-z_][A-Za-z0-9_]*)
				(?:
					\.
					([A-Za-z_][A-Za-z0-9_]*)
					)?
				(\+)?
				$///)
			[_, ident1, ident2, plus] = lMatches
			if ident2
				lFuncList.push {
					name: ident2
					object: ident1
					plus: (plus == '+')
					}
			else
				lFuncList.push {
					name: ident1
					plus: (plus == '+')
					}
		else
			croak "Bad word in func list: #{OL(word)}"
	return lFuncList

# ---------------------------------------------------------------------------
# --- export only to allow unit tests

export funcMatch = (stack, lFuncList) ->

	assert isArray(lFuncList), "not an array #{OL(lFuncList)}"

	curFunc = stack.curFunc()
	if doDebugDebug
		LOG "funcMatch(): curFunc = #{OL(curFunc)}"
		stack.dump('   ')
		LOG 'lFuncList', lFuncList
	for h in lFuncList
		{name, object, plus} = h
		if (name == curFunc)
			if doDebugDebug
				LOG "   curFunc in lFuncList - match successful"
			return true
		if plus && stack.isActive(name)
			if doDebugDebug
				LOG "   func #{OL(name)} is active - match successful"
			return true
	if doDebugDebug
		LOG "   - no match"
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
