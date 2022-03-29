# call_stack.coffee

import {undef, croak, assert} from '@jdeighan/coffee-utils'
import {log, LOG} from '@jdeighan/coffee-utils/log'

doDebugStack = false

# ---------------------------------------------------------------------------

export debugStack = (flag=true) ->

	doDebugStack = flag
	return

# ---------------------------------------------------------------------------

export class CallStack

	constructor: () ->

		@reset()

	# ........................................................................

	call: (funcName, hInfo) ->

		if doDebugStack
			prefix = '   '.repeat(@lStack.length)
			LOG "#{prefix}[--> CALL #{funcName}]"
		@lStack.push({funcName, hInfo})
		return

	# ........................................................................

	returnFrom: (fName) ->

		if @lStack.length == 0
			LOG "returnFrom('#{fName}') but stack is empty"
			return undef
		{funcName, hInfo} = @lStack.pop()
		while (funcName != fName) && (@lStack.length > 0)
			LOG "[MISSING RETURN FROM #{funcName} (return from #{fName})]"
			{funcName, hInfo} = @lStack.pop()

		if doDebugStack
			prefix = '   '.repeat(@lStack.length)
			LOG "#{prefix}[<-- BACK #{fName}]"
		if (funcName == fName)
			return hInfo
		else
			@dump()
			LOG "BAD returnFrom('#{fName}')"
			return undef

	# ........................................................................

	reset: () ->

		if doDebugStack
			LOG "RESET STACK"
		@lStack = []

	# ........................................................................

	dump: (label='CALL STACK') ->

		console.log "#{label}:"
		for item, i in @lStack
			LOG "#{i}: #{JSON.stringify(item)}"
		return
