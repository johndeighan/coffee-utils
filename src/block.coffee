# block.coffee

import fs from 'fs'
import readline from 'readline'

import {assert, croak} from '@jdeighan/base-utils/exceptions'
import {
	undef, pass, defined, notdefined, rtrim, OL, isArrayOfStrings,
	isEmpty, isString, isArray, nonEmpty, toArray, toBlock,
	} from '@jdeighan/base-utils'

# ---------------------------------------------------------------------------

export splitBlock = (block) =>

	assert isString(block), "not a string"
	pos = block.indexOf('\n')
	if (pos == -1)
		return [block, undef]
	else
		return [block.substring(0, pos), block.substring(pos+1)]


# ---------------------------------------------------------------------------

export firstLine = (block) =>

	assert isString(block), "not a string"
	pos = block.indexOf('\n')
	if (pos == -1)
		return block
	else
		return block.substring(0, pos)

# ---------------------------------------------------------------------------

export remainingLines = (block) =>

	assert isString(block), "not a string"
	pos = block.indexOf('\n')
	if (pos == -1)
		return undef
	else
		return block.substring(pos+1)

# ---------------------------------------------------------------------------
#   normalizeBlock - remove blank lines, trim each line
#                  - collapse internal whitespace to ' '

export normalizeBlock = (content) =>

	if typeof content != 'string'
		throw new Error("normalizeBlock(): not a string")
	lLines = for line in toArray(content)
		line = line.trim()
		line.replace(/\s+/g, ' ')
	lLines = lLines.filter (line) -> line != ''
	return lLines.join('\n')

# ---------------------------------------------------------------------------
# truncateBlock - limit block to a certain number of lines

export truncateBlock = (str, numLines) =>

	lLines = toArray str
	lLines.length = numLines
	return toBlock lLines

# ---------------------------------------------------------------------------

export joinBlocks = (lBlocks...) =>

	lNonEmptyBlocks = []
	for block in lBlocks.flat(999)
		assert isString(block), "joinBlocks(): #{block} is not a string"
		if nonEmpty(block)
			lNonEmptyBlocks.push block
	return lNonEmptyBlocks.join('\n')
