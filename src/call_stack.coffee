# call_stack.coffee

import {
	undef, defined, croak, assert, isBoolean, escapeStr,
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

	enter: (funcName, isLogged=false) ->

		if doDebugStack
			LOG "[--> CALL #{funcName}]"

		@lStack.push({funcName, isLogged})
		if isLogged
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

		{funcName, isLogged} = @lStack.pop()
		if isLogged && (@level > 0)
			@level -= 1

		# --- This should do nothing
		while (funcName != fName) && (@lStack.length > 0)
			LOG "[MISSING RETURN FROM #{funcName} (return from #{fName})]"
			{funcName, isLogged} = @lStack.pop()
			if isLogged && (@level > 0)
				@level -= 1

		if funcName != fName
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

	isActive: (fName) ->

		for h in @lStack
			if (h.funcName == fName)
				return true
		return false

	# ........................................................................
	# ........................................................................

	dump: (label='CALL STACK') ->

		LOG "#{label}:"
		if @lStack.length == 0
			LOG "   <EMPTY>"
		else
			for item, i in @lStack
				LOG "   #{i}: #{JSON.stringify(item)}"
		return
