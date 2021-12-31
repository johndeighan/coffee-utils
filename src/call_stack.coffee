# call_stack.coffee

import {undef, croak} from '@jdeighan/coffee-utils'
import {log} from '@jdeighan/coffee-utils/log'

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

		{funcName, hInfo} = @lStack.pop()
		if funcName != fName
			croak "returnFrom('#{fName}') but TOS is '#{funcName}'"
		return hInfo

	# ........................................................................

	reset: () ->

		@lStack = []

	# ........................................................................

	dump: (label='CALL STACK') ->

		log "#{label}:"
		for item, i in @lStack
			log "#{i}: #{JSON.stringify(item)}"
		return
