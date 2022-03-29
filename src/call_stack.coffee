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
			LOG "[CALL #{funcName}]"
		@lStack.push({funcName, hInfo})
		return

	# ........................................................................

	returnFrom: (funcName) ->

		if doDebugStack
			LOG "[RETURN FROM #{funcName}]"
		if @lStack.length == 0
			LOG "returnFrom('#{funcName}') but stack is empty"
			return undef
		TOSfName = @lStack[@lStack.length-1].funcName
		if funcName == TOSfName
			{funcName, hInfo} = @lStack.pop()
			assert funcName==TOSfName, "Bad func name on stack"
			return hInfo
		else
			@dump()
			LOG "returnFrom('#{funcName}') but TOS is '#{TOSfName}'"
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
