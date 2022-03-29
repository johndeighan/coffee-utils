# call_stack.coffee

import {undef, croak} from '@jdeighan/coffee-utils'
import {log, LOG} from '@jdeighan/coffee-utils/log'

# ---------------------------------------------------------------------------

export class CallStack

	constructor: () ->

		@reset()

	# ........................................................................

	call: (funcName, hInfo) ->

		@lStack.push({funcName, hInfo})
		return

	# ........................................................................

	returnFrom: (fName) ->

		if @lStack.length == 0
			LOG "returnFrom('#{fName}') but stack is empty"
			return undef
		{funcName, hInfo} = @lStack.pop()
		if funcName != fName
			@dump()
			LOG "returnFrom('#{fName}') but TOS is '#{funcName}'"
		return hInfo

	# ........................................................................

	reset: () ->

		@lStack = []

	# ........................................................................

	dump: (label='CALL STACK') ->

		console.log "#{label}:"
		for item, i in @lStack
			LOG "#{i}: #{JSON.stringify(item)}"
		return
