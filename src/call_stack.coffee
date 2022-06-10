# call_stack.coffee

import {
	undef, defined, croak, assert, OL, isBoolean, escapeStr,
	} from '@jdeighan/coffee-utils'
import {log, LOG} from '@jdeighan/coffee-utils/log'
import {getPrefix} from '@jdeighan/coffee-utils/arrow'

doDebugStack = false

# ---------------------------------------------------------------------------

export debugStack = (flag=true) ->

	doDebugStack = flag
	return

# ---------------------------------------------------------------------------

export class CallStack

	constructor: () ->

		@lStack = []
		@level = 0

	# ........................................................................

	reset: () ->

		if doDebugStack
			LOG "RESET STACK"
		@lStack = []
		@level = 0
		return

	# ........................................................................

	enter: (funcName, oldFlag=undef) ->
		# --- funcName might be <object>.<method>

		assert (oldFlag == undef), "enter() takes only 1 arg"
		if doDebugStack
			LOG "[--> ENTER #{funcName}]"

		lMatches = funcName.match(///^
				([A-Za-z_][A-Za-z0-9_]*)
				(?:
					\.
					([A-Za-z_][A-Za-z0-9_]*)
					)?
				$///)
		assert defined(lMatches), "Bad funcName: #{OL(funcName)}"
		[_, ident1, ident2] = lMatches
		if ident2
			@lStack.push({
				fullName: "#{ident1}.#{ident2}"
				funcName: ident2
				isLogged: false
				})
		else
			@lStack.push({
				fullName: ident1
				funcName: ident1
				isLogged: false
				})
		return

	# ........................................................................

	isLogging: () ->

		if (@lStack.length == 0)
			return false
		else
			return @lStack[@lStack.length - 1].isLogged

	# ........................................................................

	isLoggingPrev: () ->

		if (@lStack.length < 2)
			return false
		else
			return @lStack[@lStack.length - 2].isLogged

	# ........................................................................

	logCurFunc: () ->

		# --- funcName must be  the current function
		#     and the isLogged flag must currently be false
		cur = @lStack[@lStack.length - 1]
		assert (cur.isLogged == false), "isLogged is already true"
		cur.isLogged = true
		@level += 1
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	returnFrom: (fName) ->

		if doDebugStack
			LOG "[<-- BACK #{fName}]"

		if @lStack.length == 0
			LOG "ERROR: returnFrom('#{funcName}') but stack is empty"
			return

		{fullName, isLogged} = @lStack.pop()
		if isLogged && (@level > 0)
			@level -= 1

		# --- This should do nothing
		while (fullName != fName) && (@lStack.length > 0)
			LOG "[MISSING RETURN FROM #{fullName} (return from #{fName})]"
			{fullName, isLogged} = @lStack.pop()
			if isLogged && (@level > 0)
				@level -= 1

		if fullName != fName
			@dump()
			LOG "BAD BAD BAD BAD returnFrom('#{fName}')"
		return

	# ........................................................................

	getLevel: () ->

		return @level

	# ........................................................................

	curFunc: () ->

		if (@lStack.length == 0)
			return 'main'
		else
			return @lStack[@lStack.length - 1].funcName

	# ........................................................................

	isActive: (funcName) ->
		# --- funcName won't be <obj>.<method>
		#     but the stack might contain that form

		for h in @lStack
			if (h.funcName == funcName)
				return true
		return false

	# ........................................................................
	# ........................................................................

	dump: (prefix='', label='CALL STACK') ->

		LOG "#{label}:"
		if @lStack.length == 0
			LOG "   <EMPTY>"
		else
			for item, i in @lStack
				LOG "   #{i}: #{JSON.stringify(item)}"
		return
