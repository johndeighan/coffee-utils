# debug_utils.coffee

import {
	assert, undef, error, croak, warn, defined,
	isString, isFunction, isBoolean, patchStr,
	OL, escapeStr, isNumber, isArray, words, pass,
	} from '@jdeighan/coffee-utils'
import {blockToArray} from '@jdeighan/coffee-utils/block'
import {untabify} from '@jdeighan/coffee-utils/indent'
import {slurp} from '@jdeighan/coffee-utils/fs'
import {CallStack} from '@jdeighan/coffee-utils/stack'
import {
	prefix, addArrow, removeLastVbar, vbar,
	} from '@jdeighan/coffee-utils/arrow'
import {
	log, logItem, logBareItem, LOG, shortEnough,
	} from '@jdeighan/coffee-utils/log'

# --- set in resetDebugging() and setDebugging()
export callStack = new CallStack()
export shouldLog = () -> undef

lFuncList = []          # names of functions being debugged
strFuncList = undef     # original string

# ---------------------------------------------------------------------------

export interp = (label) ->

	return label.replace(/// \$ (\@)? ([A-Za-z_][A-Za-z0-9_]*) ///g,
			(_, atSign, varName) ->
				if atSign
					return "\#{OL(@#{varName})\}"
				else
					return "\#{OL(#{varName})\}"
			)

# ---------------------------------------------------------------------------

export debug = (orgLabel, lObjects...) ->

	assert isString(orgLabel), "1st arg #{OL(orgLabel)} should be a string"

	[type, funcName] = getType(orgLabel, lObjects)
	label = shouldLog(orgLabel, type, funcName, callStack)
	if defined(label)
		label = interp(label)

	switch type

		when 'enter'
			if defined(label)
				doTheLogging type, label, lObjects
			callStack.enter funcName, lObjects, defined(label)

			debug2 "enter debug()", orgLabel, lObjects
			debug2 "type = #{OL(type)}, funcName = #{OL(funcName)}"
			debug2 "return from debug()"

		when 'return'
			debug2 "enter debug()", orgLabel, lObjects
			debug2 "type = #{OL(type)}, funcName = #{OL(funcName)}"
			debug2 "return from debug()"

			if defined(label)
				doTheLogging type, label, lObjects
			callStack.returnFrom funcName

		when 'string'
			debug2 "enter debug()", orgLabel, lObjects
			debug2 "type = #{OL(type)}, funcName = #{OL(funcName)}"

			if defined(label)
				doTheLogging type, label, lObjects
			debug2 "return from debug()"

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export debug2 = (orgLabel, lObjects...) ->

	[type, funcName] = getType(orgLabel, lObjects)
	label = shouldLog(orgLabel, type, funcName, callStack)

	switch type
		when 'enter'
			if defined(label)
				doTheLogging 'enter', label, lObjects
			callStack.enter funcName, lObjects, defined(label)

		when 'return'
			if defined(label)
				doTheLogging 'return', label, lObjects
			callStack.returnFrom funcName

		when 'string'
			if defined(label)
				doTheLogging 'string', label, lObjects

	return true   # allow use in boolean expressions

# ---------------------------------------------------------------------------

export doTheLogging = (type, label, lObjects) ->

	assert isString(label), "non-string label #{OL(label)}"
	level = callStack.getLevel()

	switch type

		when 'enter'
			log label, prefix(level)
			if label.match(///^ \s* call///)
				pre = prefix(level+1, 'noLastVbar')
				itemPre = prefix(level+2, 'noLast2Vbars')
			else
				pre = prefix(level+1)
				itemPre = prefix(level+2, 'noLastVbar')
			for obj,i in lObjects
				logItem "arg[#{i}]", obj, pre, itemPre

		when 'return'
			log label, prefix(level, 'withArrow')
			pre = prefix(level, 'noLastVbar')
			itemPre = prefix(level+1, 'noLast2Vbars')
			for obj,i in lObjects
				logItem "ret[#{i}]", obj, pre, itemPre
		when 'string'
			pre = prefix(level)
			itemPre = prefix(level+1, 'noLastVbar')
			if (lObjects.length==0)
				log label, pre
			else if (lObjects.length==1) && shortEnough(label, lObjects[0])
				logItem label, lObjects[0], pre
			else
				if (label.indexOf(':') != label.length - 1)
					label += ':'
				log label, pre
				for obj in lObjects
					logBareItem obj, itemPre
	return

# ---------------------------------------------------------------------------

export stdShouldLog = (label, type, funcName, stack) ->
	# --- if type is 'enter', then funcName won't be on the stack yet
	#     returns the (possibly modified) label to log

	assert isString(label), "label #{OL(label)} not a string"
	assert isString(type),  "type #{OL(type)} not a string"
	assert stack instanceof CallStack, "not a call stack object"
	if (type == 'enter') || (type == 'return')
		assert isString(funcName), "func name #{OL(funcName)} not a string"
	else
		assert funcName == undef, "func name #{OL(funcName)} not undef"

	if funcMatch(funcName || stack.curFunc())
		return label

	if (type == 'enter') && ! isMyFunc(funcName)
		# --- As a special case, if we enter a function where we will not
		#     be logging, but we were logging in the calling function,
		#     we'll log out the call itself

		if funcMatch(stack.curFunc())
			result = label.replace('enter', 'call')
			return result
	return undef

# ---------------------------------------------------------------------------

export isMyFunc = (funcName) ->

	return funcName in words('debug debug2 doTheLogging
			stdShouldLog setDebugging getFuncList funcMatch
			getType dumpCallStack')

# ---------------------------------------------------------------------------

export trueShouldLog = (label, type, funcName, stack) ->

	if isMyFunc(funcName || stack.curFunc())
		return undef
	else
		return label

# ---------------------------------------------------------------------------

export setDebugging = (option) ->

	callStack.reset()
	if isBoolean(option)
		if option
			shouldLog = trueShouldLog
		else
			shouldLog = () -> return undef
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

export funcMatch = (funcName) ->

	assert isArray(lFuncList), "not an array #{OL(lFuncList)}"
	for h in lFuncList
		{name, object, plus} = h
		if (name == funcName)
			return true
		if plus && callStack.isActive(name)
			return true
	return false

# ---------------------------------------------------------------------------
# --- type is one of: 'enter', 'return', 'string'

export getType = (str, lObjects) ->

	if lMatches = str.match(///^
			\s*
			( enter | (?: return .+ from ) )
			\s+
			([A-Za-z_][A-Za-z0-9_]*)
			(?:
				\.
				([A-Za-z_][A-Za-z0-9_]*)
				)?
			///)
		[_, type, ident1, ident2] = lMatches

		if ident2
			funcName = ident2
		else
			funcName = ident1

		if (type == 'enter')
			return ['enter', funcName]
		else
			return ['return', funcName]
	else
		return ['string', undef]

# ---------------------------------------------------------------------------

reMethod = ///^
	([A-Za-z_][A-Za-z0-9_]*)
	\.
	([A-Za-z_][A-Za-z0-9_]*)
	$///

# ---------------------------------------------------------------------------

export dumpDebugGlobals = () ->

	LOG '='.repeat(40)
	LOG callStack.dump()
	if shouldLog == stdShouldLog
		LOG "using stdShouldLog"
	else if shouldLog == trueShouldLog
		LOG "using trueShouldLog"
	else
		LOG "using custom shouldLog"
	LOG "lFuncList:"
	for funcName in lFuncList
		LOG "   #{OL(funcName)}"
	LOG '='.repeat(40)

# ---------------------------------------------------------------------------
