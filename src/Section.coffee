# Section.coffee

import {
	assert, pass, undef, defined, croak, isArray,
	} from '@jdeighan/coffee-utils'
import {arrayToBlock} from '@jdeighan/coffee-utils/block'
import {indented} from '@jdeighan/coffee-utils/indent'

# ---------------------------------------------------------------------------

export class Section

	constructor: () ->

		@lLines = []

	# ..........................................................

	length: () ->

		return @lLines.length

	# ..........................................................

	indent: (level=1) ->

		lNewLines = for line in @lLines
			indented(line, level)
		@lLines = lNewLines
		return

	# ..........................................................

	isEmpty: () ->

		return (@lLines.length == 0)

	# ..........................................................

	nonEmpty: () ->

		return (@lLines.length > 0)

	# ..........................................................

	add: (data) ->

		if isArray(data)
			for line in data
				@lLines.push line
		else
			@lLines.push data
		return

	# ..........................................................

	prepend: (data) ->

		if isArray(data)
			@lLines = [data..., @lLines...]
		else
			@lLines = [data, @lLines...]
		return

	# ..........................................................

	getBlock: () ->

		return arrayToBlock(@lLines)
