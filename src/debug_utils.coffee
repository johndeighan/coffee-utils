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

# --- set in resetDebugging() and setDebugging()
export callStack = new CallStack()
export shouldLog = () -> undef

lFuncList = []
strFuncList = undef     # original string

# --- internal debugging
doDebugDebug = false
lFunctions = undef     # --- only used when doDebugDebug is true

# ---------------------------------------------------------------------------

export dumpCallStack = (label) ->

	LOG callStack.dump('', label)
	return

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

debugDebug = (label, lObjects...) ->
	# --- For debugging functions in this module

	if ! doDebugDebug
		return

	# --- At this point, doDebugDebug is true
	doDebugDebug = false   # temp - reset before returning

	assert isString(label), "1st arg #{OL(label)} should be a string"
	nObjects = lObjects.length
	[type, funcName] = getType(label, nObjects)

	switch type
		when 'enter'
			assert defined(funcName), "type enter, funcName = undef"
			callStack.enter funcName
			doLog = (lFunctions == undef) || (funcName in lFunctions)

		when 'return'
			assert defined(funcName), "type return, funcName = undef"
			doLog = (lFunctions == undef) || (funcName in lFunctions)

		when 'string'
			assert (funcName == undef), "type string, funcName defined"
			assert (nObjects == 0), "Objects not allowed for #{OL(type)}"
			doLog = true

		when 'objects'
			assert (funcName == undef), "type objects, funcName defined"
			assert (nObjects > 0), "Objects required for #{OL(type)}"
			dolog = true

	if doLog
		doTheLogging type, label, lObjects

	if (type == 'enter') && doLog
		callStack.logCurFunc(funcName)
	else if (type == 'return')
		callStack.returnFrom funcName

	doDebugDebug = true
	return

# ---------------------------------------------------------------------------

export debug = (label, lObjects...) ->

	assert isString(label), "1st arg #{OL(label)} should be a string"

	# --- If label is "enter <funcname>, we need to put that on the stack
	#     BEFORE we do any internal logging
	nObjects = lObjects.length
	[type, funcName] = getType(label, nObjects)
	if (type == 'enter')
		callStack.enter funcName

	debugDebug "enter debug(#{OL(label)})", lObjects...
	debugDebug "type = #{OL(type)}"
	debugDebug "funcName = #{OL(funcName)}"

	# --- function shouldLog() returns the (possibly modified) label
	#     if we should log this, else it returns undef

	switch type
		when 'enter'
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
	debugDebug "doLog = #{OL(doLog)}"
	debugDebug "#{nObjects} objects"

	if doLog
		doTheLogging type, label, lObjects

	if (type == 'enter') && doLog && (label.indexOf('call') == -1)
		callStack.logCurFunc(funcName)

	# --- This must be called BEFORE we return from funcName
	debugDebug "return from debug()"

	if (type == 'return')
		callStack.returnFrom funcName

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export doTheLogging = (type, label, lObjects) ->

	level = callStack.getLevel()
	prefix = getPrefix(level)
	itemPrefix = removeLastVbar(prefix)
	sep = dashes(itemPrefix, 40)
	assert isString(sep), "sep is not a string"

	debugDebug "callStack", callStack
	debugDebug "level = #{OL(level)}"
	debugDebug "prefix = #{OL(prefix)}"
	debugDebug "itemPrefix = #{OL(itemPrefix)}"
	debugDebug "sep = #{OL(sep)}"

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
			if (lObjects.length==1) && shortEnough(label, lObjects[0])
				logItem label, lObjects[0], {prefix}
			else
				if (label.indexOf(':') != label.length - 1)
					label += ':'
				log label, {prefix}
				for obj in lObjects
					logItem undef, obj, {prefix}
	return

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

	debugDebug "enter stdShouldLog(#{OL(label)}, #{OL(type)}, #{OL(funcName)}, stack)"

	switch type
		when 'enter'
			if funcMatch()
				debugDebug "return #{OL(label)} from stdShouldLog() - funcMatch"
				return label

			else
				# --- As a special case, if we enter a function where we will not
				#     be logging, but we were logging in the calling function,
				#     we'll log out the call itself

				prevLogged = stack.isLoggingPrev()
				if prevLogged
					result = label.replace('enter', 'call')
					debugDebug "return #{OL(result)} from stdShouldLog() - s/enter/call/"
					return result
		else
			if funcMatch()
				debugDebug "return #{OL(label)} from stdShouldLog()"
				return label
	debugDebug "return undef from stdShouldLog()"
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

	strFuncList = str     # store original string for debugging
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

export funcMatch = () ->

	assert isArray(lFuncList), "not an array #{OL(lFuncList)}"

	debugDebug "enter funcMatch()"
	curFunc = callStack.curFunc()
	debugDebug "curFunc = #{OL(curFunc)}"
	debugDebug "lFuncList = #{strFuncList}"
	for h in lFuncList
		{name, object, plus} = h
		if (name == curFunc)
			debugDebug "return from funcMatch() - curFunc in lFuncList"
			return true
		if plus && callStack.isActive(name)
			debugDebug "return from funcMatch() - func #{OL(name)} is active"
			return true
	debugDebug "return from funcMatch() - no match"
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

