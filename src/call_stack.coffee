# call_stack.coffee

import {undef, croak, assert} from '@jdeighan/coffee-utils'
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

		@reset()

	# ........................................................................

	reset: () ->

		if doDebugStack
			LOG "RESET STACK"

		@lStack = []
		@level = 0
		return

	# ........................................................................

	addCall: (funcName, hInfo, isLogged) ->

		@lStack.push({funcName, hInfo, isLogged})
		if isLogged
			@level += 1
		return

	# ........................................................................

	removeCall: (fName) ->

		{funcName, hInfo, isLogged} = @lStack.pop()
		if isLogged && (@level > 0)
			@level -= 1
		while (funcName != fName) && (@lStack.length > 0)
			LOG "[MISSING RETURN FROM #{funcName} (return from #{fName})]"
			{funcName, hInfo, isLogged} = @lStack.pop()
			if isLogged && (@level > 0)
				@level -= 1

		if funcName == fName
			return hInfo
		else
			@dump()
			LOG "BAD BAD BAD BAD returnFrom('#{fName}')"
			return undef

	# ........................................................................
	# ........................................................................

	call: (funcName, hInfo, isLogged=undef) ->

		assert isLogged != undef, "CallStack.call(): 3 args required"
		mainPre = getPrefix(@level)

		if doDebugStack
			prefix = '   '.repeat(@lStack.length)
			LOG "#{prefix}[--> CALL #{funcName}]"

		@addCall funcName, hInfo, isLogged
		auxPre = getPrefix(@level)
		return [mainPre, auxPre, undef]

	# ........................................................................

	logStr: () ->

		pre = getPrefix(@level)
		return [pre, pre, undef]

	# ........................................................................

	returnFrom: (funcName) ->

		# --- Prefixes are based on level before stack adjustment
		mainPre = getPrefix(@level, 'withArrow')
		auxPre = getPrefix(@level, 'returnVal')

		if @lStack.length == 0
			LOG "returnFrom('#{fName}') but stack is empty"
			return [mainPre, auxPre, undef]

		hInfo = @removeCall(funcName)
		if doDebugStack
			prefix = '   '.repeat(@lStack.length)
			LOG "#{prefix}[<-- BACK #{fName}]"

		return [mainPre, auxPre, hInfo]

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
