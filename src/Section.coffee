# Section.coffee

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {dbg, dbgEnter, dbgReturn} from '@jdeighan/base-utils/debug'
import {
	pass, undef, defined, isArray, isEmpty, isFunction, toBlock,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export class Section

	constructor: (@name, @replacer=undef) ->
		# --- name can be undef or empty

		@lParts = []
		if defined(@replacer)
			assert isFunction(@replacer), "bad replacer"

	# ..........................................................

	isEmpty: () ->

		return (@lParts.length == 0)

	# ..........................................................

	nonEmpty: () ->

		return (@lParts.length > 0)

	# ..........................................................

	add: (data) ->

		if isArray(data)
			for line in data
				@lParts.push line
		else
			@lParts.push data
		return

	# ..........................................................

	prepend: (data) ->

		if isArray(data)
			@lParts = [data..., @lParts...]
		else
			@lParts = [data, @lParts...]
		return

	# ..........................................................

	getParts: () ->

		return @lParts

	# ..........................................................

	getBlock: () ->

		dbgEnter "Section.getBlock"
		if (@lParts.length == 0)
			dbgReturn "Section.getBlock", undef
			return undef
		block = toBlock(@lParts)
		if defined(@replacer)
			block = @replacer block
		dbgReturn "Section.getBlock", block
		return block
