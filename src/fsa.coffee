# fsa.coffee

import {assert, croak} from '@jdeighan/exceptions'
import {LOG} from '@jdeighan/exceptions/log'
import {debug} from '@jdeighan/exceptions/debug'
import {
	undef, defined, notdefined, words, isEmpty, nonEmpty,
	isString, OL,
	} from '@jdeighan/coffee-utils'
import {toArray} from '@jdeighan/coffee-utils/block'

# ---------------------------------------------------------------------------

export class FSA

	constructor: (block) ->

		debug "enter FSA()"
		assert isString(block), "block not a string"
		@hTransitions = {}
		lLines = toArray(block, 'noEmptyLines')
		debug 'lLines', lLines
		for line,i in lLines
			debug "LINE #{i}", line
			lWords = words(line)
			if (lWords.length == 3)
				[bState, token, eState] = lWords
				output = undef
			else if (lWords.length == 4)
				[bState, token, eState, output] = lWords
			else
				croak "Invalid desc: #{OL(line)}"
			debug "LINE #{i}: #{OL(bState)} #{OL(token)} #{OL(eState)} #{OL(output)}"
			assert nonEmpty(eState), "Invalid FSA description #{i}"

			# --- tokens may be quoted (but may not contain whitespace),
			#     but the quotes are stripped
			if (i == 0)
				assert (bState == 'start'), "Invalid FSA description #{i}"
			token = @fixToken(token)
			debug 'token', token
			if isEmpty(output)
				output = undef
			hTrans = @hTransitions[bState]
			if notdefined(hTrans)
				hTrans = @hTransitions[bState] = {}
			assert notdefined(hTrans[token]), "Duplicate transition"
			hTrans[token] = [eState, output]
		debug 'hTransitions', @hTransitions
		@curState = 'start'
		debug "return from FSA()"

	# ..........................................................

	fixToken: (token) ->

		if lMatches = token.match(/^\'(.*)\'$/)
			return lMatches[1]
		else if lMatches = token.match(/^\"(.*)\"$/)
			return lMatches[1]
		else
			return token

	# ..........................................................

	got: (token) ->
		# --- returns pair [newState, output]

		hTrans = @hTransitions[@curState]
		if notdefined(hTrans)
			return [undef, undef]
		result = hTrans[token]
		if notdefined(result)
			return [undef, undef]
		[newState, output] = result
		assert nonEmpty(newState), "Failed: #{@curState} -> #{token}"
		@curState = newState
		return result

	# ..........................................................

	state: () ->
		return @curState
