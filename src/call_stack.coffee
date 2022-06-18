# call_stack.coffee

import {
	undef, defined, croak, assert, OL, isBoolean, escapeStr, deepCopy,
	} from '@jdeighan/coffee-utils'
import {LOG} from '@jdeighan/coffee-utils/log'

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

	enter: (funcName, lArgs=[]) ->
		# --- funcName might be <object>.<method>

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
				fullName: funcName     #    "#{ident1}.#{ident2}"
				funcName: ident2
				isLogged: false
				lArgs: deepCopy(lArgs)
				})
		else
			@lStack.push({
				fullName: funcName
				funcName: ident1
				isLogged: false
				lArgs: deepCopy(lArgs)
				})
		return

	# ........................................................................

	getLevel: () ->

		return @level

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

	logCurFunc: (funcName) ->

		# --- funcName must be  the current function
		#     and the isLogged flag must currently be false

		cur = @lStack[@lStack.length - 1]
		assert (cur.isLogged == false), "isLogged is already true"
		if (funcName != cur.fullName)
			LOG "cur func #{cur.fullName} is not #{funcName}"
			LOG @dump()
			croak "BAD"
		cur.isLogged = true
		@level += 1
		return

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	returnFrom: (fName) ->

		if doDebugStack
			LOG "[<-- BACK #{fName}]"

		if @lStack.length == 0
			LOG "ERROR: returnFrom('#{fName}') but stack is empty"
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

	dump: () ->

		lLines = ["CALL STACK:"]
		if @lStack.length == 0
			lLines.push "   <EMPTY>"
		else
			for item, i in @lStack
				lLines.push "   " + @callStr(i, item)
		return lLines.join("\n")

	# ........................................................................

	callStr: (i, item) ->

		sym = if item.isLogged then '*' else ''
		str = "#{i}#{sym}: #{item.fullName}"
		for arg in item.lArgs
			str += " #{OL(arg)}"
		return str

	# ........................................................................

	sdump: (label='CALL STACK') ->

		lFuncNames = []
		for item in @lStack
			if item.isLogged
				lFuncNames.push '*' + item.fullName
			else
				lFuncNames.push item.fullName
		if @lStack.length == 0
			return "#{label} <EMPTY>"
		else
			return "#{label} #{lFuncNames.join(' ')}"
