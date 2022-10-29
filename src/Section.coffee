# Section.coffee

import {assert, croak} from '@jdeighan/exceptions'
import {debug} from '@jdeighan/exceptions/debug'
import {
	pass, undef, defined, isArray, isEmpty, isFunction,
	} from '@jdeighan/coffee-utils'
import {toBlock} from '@jdeighan/coffee-utils/block'

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

		debug "enter Section.getBlock()"
		if (@lParts.length == 0)
			debug "return undef from Section.getBlock()"
			return undef
		block = toBlock(@lParts)
		if defined(@replacer)
			block = @replacer block
		debug "return from Section.getBlock()", block
		return block
