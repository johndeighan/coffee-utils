# call_stack.coffee

import {assert, croak} from '@jdeighan/unit-tester/utils'
import {
	undef, defined, OL,  escapeStr, deepCopy,
	isArray, isBoolean,
	} from '@jdeighan/coffee-utils'

doDebugStack = false

# ---------------------------------------------------------------------------

export debugStack = (flag=true) ->

	doDebugStack = flag
	return

# ---------------------------------------------------------------------------

export class CallStack

	constructor: () ->

		@lStack = []

	# ........................................................................

	reset: () ->

		if doDebugStack
			console.log "RESET STACK"
		@lStack = []
		return

	# ........................................................................

	indent: () ->

		return '   '.repeat(@lStack.length)

	# ........................................................................

	enter: (funcName, lArgs=[], isLogged) ->
		# --- funcName might be <object>.<method>

		assert isArray(lArgs), "missing lArgs"
		assert isBoolean(isLogged), "missing isLogged"

		if doDebugStack
			console.log @indent() + "[--> ENTER #{funcName}]"

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
			hStackItem = {
				fullName: funcName     #    "#{ident1}.#{ident2}"
				funcName: ident2
				isLogged
				lArgs: deepCopy(lArgs)
				}
		else
			hStackItem = {
				fullName: funcName
				funcName: ident1
				isLogged
				lArgs: deepCopy(lArgs)
				}
		@lStack.push hStackItem
		return hStackItem

	# ........................................................................

	getLevel: () ->

		level = 0
		for item in @lStack
			if item.isLogged
				level += 1
		return level

	# ........................................................................

	isLogging: () ->

		if (@lStack.length == 0)
			return false
		else
			return @lStack[@lStack.length - 1].isLogged

	# ........................................................................
	# --- if stack is empty, log the error, but continue

	returnFrom: (fName) ->

		if @lStack.length == 0
			console.log "ERROR: returnFrom('#{fName}') but stack is empty"
			return
		{fullName, isLogged} = @lStack.pop()
		if doDebugStack
			console.log @indent() + "[<-- BACK #{fName}]"
		if (fullName != fName)
			console.log "ERROR: returnFrom('#{fName}') but TOS is #{fullName}"
			return

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

	dump: (label="CALL STACK") ->

		lLines = [label]
		if @lStack.length == 0
			lLines.push "   <EMPTY>"
		else
			for item, i in @lStack
				lLines.push "   " + @callStr(i, item)
		return lLines.join("\n")

	# ........................................................................

	callStr: (i, item) ->

		sym = if item.isLogged then '*' else '-'
		str = "#{i}: #{sym}#{item.fullName}"
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
