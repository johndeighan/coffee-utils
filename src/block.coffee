# block.coffee

import fs from 'fs'
import readline from 'readline'

import {assert, croak} from '@jdeighan/base-utils'
import {blockToArray, arrayToBlock} from '@jdeighan/base-utils/utils'
import {
	undef, pass, defined, notdefined,
	isEmpty, isString, isArray, nonEmpty, isArrayOfStrings,
	rtrim, OL,
	} from '@jdeighan/coffee-utils'

export {blockToArray, arrayToBlock}

# ---------------------------------------------------------------------------
#   toArray - split a block or array into lines w/o newlines

export toArray = (item, option=undef) ->
	# --- Valid options:
	#     'noEmptyLines'
	#     'noLeadingEmptyLines'

	if isString(item)
		lLines = item.split(/\r?\n/)
	else if isArray(item)
		lLines = item
	else
		croak "Not a string or array"

	# --- We need to ensure that no strings contain newlines
	#     and possibly remove empty lines
	lNewLines = []
	nonEmptyFound = false
	for line in lLines
		if isEmpty(line)
			if (option == 'noEmptyLines') \
					|| ((option == 'noLeadingEmptyLines') && ! nonEmptyFound)
				pass
			else
				lNewLines.push ''
		else if (line.indexOf("\n") > -1)
			for substr in toArray(line)
				if isEmpty(substr)
					if (option == 'noEmptyLines') \
							|| ((option == 'noLeadingEmptyLines') && ! nonEmptyFound)
						pass
					else
						lNewLines.push ''
				else
					nonEmptyFound = true
					lNewLines.push substr
		else
			nonEmptyFound = true
			lNewLines.push line
	return lNewLines

# ---------------------------------------------------------------------------
#   toBlock - block may have trailing whitespace
#             but undef items are ignored

export toBlock = (lLines) ->

	if notdefined(lLines)
		return undef
	assert isArrayOfStrings(lLines),
		"lLines is not an array of strings: #{OL(lLines)}"
	lNewLines = []
	for line in lLines
		if defined(line)
			lNewLines.push rtrim(line)
	return lNewLines.join("\n")

# ---------------------------------------------------------------------------

export splitBlock = (block) ->

	assert isString(block), "not a string"
	pos = block.indexOf('\n')
	if (pos == -1)
		return [block, undef]
	else
		return [block.substring(0, pos), block.substring(pos+1)]


# ---------------------------------------------------------------------------

export firstLine = (block) ->

	assert isString(block), "not a string"
	pos = block.indexOf('\n')
	if (pos == -1)
		return block
	else
		return block.substring(0, pos)

# ---------------------------------------------------------------------------

export remainingLines = (block) ->

	assert isString(block), "not a string"
	pos = block.indexOf('\n')
	if (pos == -1)
		return undef
	else
		return block.substring(pos+1)

# ---------------------------------------------------------------------------
#   normalizeBlock - remove blank lines, trim each line
#                  - collapse internal whitespace to ' '

export normalizeBlock = (content) ->

	if typeof content != 'string'
		throw new Error("normalizeBlock(): not a string")
	lLines = for line in blockToArray(content)
		line = line.trim()
		line.replace(/\s+/g, ' ')
	lLines = lLines.filter (line) -> line != ''
	return lLines.join('\n')

# ---------------------------------------------------------------------------
# truncateBlock - limit block to a certain number of lines

export truncateBlock = (str, numLines) ->

	lLines = blockToArray str
	lLines.length = numLines
	return arrayToBlock lLines

# ---------------------------------------------------------------------------

export joinBlocks = (lBlocks...) ->

	lNonEmptyBlocks = []
	for block in lBlocks.flat(999)
		assert isString(block), "joinBlocks(): #{block} is not a string"
		if nonEmpty(block)
			lNonEmptyBlocks.push block
	return lNonEmptyBlocks.join('\n')
