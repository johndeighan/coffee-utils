# Section.coffee

import {assert, error, croak} from '@jdeighan/unit-tester/utils'
import {
	pass, undef, defined, isArray, isEmpty,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {indented} from '@jdeighan/coffee-utils/indent'
import {debug} from '@jdeighan/coffee-utils/debug'

# ---------------------------------------------------------------------------

export class Section

	constructor: (@name, content=undef) ->
		# --- name can be undef or empty

		@lParts = []
		if defined(content)
			@lParts.push content

	# ..........................................................

	length: () ->

		return @lParts.length

	# ..........................................................

	indent: (level=1, oneIndent="\t") ->

		lNewLines = for line in @lParts
			indented(line, level, oneIndent)
		@lParts = lNewLines
		return

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
		else
			result = arrayToBlock(@lParts)
			debug "return from Section.getBlock()", result
			return result
