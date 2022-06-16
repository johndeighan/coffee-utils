# debug_utils.coffee

import {
	assert, undef, error, croak, warn, defined,
	isString, isFunction, isBoolean,
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
	log, logItem, LOG, shortEnough, dashes,
	} from '@jdeighan/coffee-utils/log'

callStack = new CallStack()

# --- set in resetDebugging() and setDebugging()
export shouldLog = () -> undef
export lFuncList = []

# --- internal debugging
doDebugDebug = false
lFunctions = undef     # --- only used when doDebugDebug is true

# ---------------------------------------------------------------------------

export setDebugDebugging = (value=true) ->
	# --- value can be a boolean or string of words

	if isBoolean(value)
		doDebugDebug = value
	else if isString(value)
		doDebugDebug = true
		lFunctions = words(value)
	else
		croak "Bad value: #{OL(value)}"
	return

# ---------------------------------------------------------------------------

logif = (label, lObjects...) ->

	if ! doDebugDebug
		return

	assert isString(label), "1st arg #{OL(label)} should be a string"
	nObjects = lObjects.length
	[type, funcName] = getType(label, nObjects)
	switch type
		when 'enter'
			if defined(lFunctions) && (funcName not in lFunctions)
				return
			callStack.enter funcName
			log label, lObjects...
		when 'return'
			if defined(lFunctions) && (funcName not in lFunctions)
				return
			log label, lObjects...
			callStack.returnFrom funcName
		when 'string'
			log label, lObjects...
		when 'objects'
			log label, lObjects...
	return

# ---------------------------------------------------------------------------

export debug = (label, lObjects...) ->

	logif "enter debug(#{OL(label)})", lObjects...

	assert isString(label), "1st arg #{OL(label)} should be a string"

	# --- We want to allow objects to be undef. Therefore, we need to
	#     distinguish between 1 arg sent vs. 2 or more args sent
	nObjects = lObjects.length

	# --- funcName is only set for types 'enter' and 'return'
	[type, funcName] = getType(label, nObjects)
	logif "type = #{OL(type)}"
	logif "funcName = #{OL(funcName)}"

	# --- function shouldLog() returns the (possibly modified) label
	#     if we should log this, else it returns undef

	switch type
		when 'enter'
			callStack.enter funcName
			label = shouldLog(label, type, funcName, callStack)
		when 'return'
			label = shouldLog(label, type, funcName, callStack)
		when 'string'
			label = shouldLog(label, type, undef, callStack)
			assert (nObjects == 0),
					"Objects not allowed for #{OL(type)}"
		when 'objects'
			label = shouldLog(label, type, undef, callStack)
			assert (nObjects > 0),
					"Objects required for #{OL(type)}"

	assert (label == undef) || isString(label),
			"label not a string: #{OL(label)}"
	doLog = defined(label)
	logif "doLog = #{OL(doLog)}"
	logif "#{nObjects} objects"

	if doLog
		level = callStack.getLevel()
		prefix = getPrefix(level)
		itemPrefix = removeLastVbar(prefix)
		sep = dashes(itemPrefix, 40)
		assert isString(sep), "sep is not a string"

		logif "callStack", callStack
		logif "level = #{OL(level)}"
		logif "prefix = #{OL(prefix)}"
		logif "itemPrefix = #{OL(itemPrefix)}"
		logif "sep = #{OL(sep)}"

		switch type
			when 'enter'
				log label, {prefix}
				for obj,i in lObjects
					if (i > 0)
						log sep
					logItem undef, obj, {itemPrefix}
			when 'return'
				log label, {prefix: addArrow(prefix)}
				for obj,i in lObjects
					if (i > 0)
						log sep
					logItem undef, obj, {itemPrefix}
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

	logif "return from debug()"
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

	logif "stdShouldLog(#{OL(label)}, #{OL(type)}, #{OL(funcName)}, stack)"
	logif "stack", stack
	logif "lFuncList", lFuncList

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

export setDebugging = (option) ->

	callStack.reset()
	if isBoolean(option)
		if option
			shouldLog = (label, type, funcName, stack) -> label
		else
			shouldLog = (label, type, funcName, stack) -> undef
	else if isString(option)
		lFuncList = getFuncList(option)
		shouldLog = stdShouldLog
	else if isFunction(option)
		shouldLog = option
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
	logif "funcMatch(): curFunc = #{OL(curFunc)}"
	logif stack.dump('   ')
	logif 'lFuncList', lFuncList
	for h in lFuncList
		{name, object, plus} = h
		if (name == curFunc)
			logif "   curFunc in lFuncList - match successful"
			return true
		if plus && stack.isActive(name)
			logif "   func #{OL(name)} is active - match successful"
			return true
	logif "   - no match"
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

