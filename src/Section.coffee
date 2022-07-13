# Section.coffee

import {
	assert, pass, undef, defined, croak, isArray,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {indented} from '@jdeighan/coffee-utils/indent'

# ---------------------------------------------------------------------------

export class Section

	constructor: (@name) ->

		@lParts = []

	# ..........................................................

	length: () ->

		return @lParts.length

	# ..........................................................

	indent: (level=1) ->

		lNewLines = for line in @lParts
			indented(line, level)
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

		if (@lParts.length == 0)
			return undef
		else
			return arrayToBlock(@lParts)
