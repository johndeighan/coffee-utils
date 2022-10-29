# block.coffee

import fs from 'fs'
import readline from 'readline'

import {assert, croak} from '@jdeighan/exceptions'
import {blockToArray, arrayToBlock} from '@jdeighan/exceptions/utils'
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

# ---------------------------------------------------------------------------

```
export async function forEachLine(filepath, func) {

const fileStream = fs.createReadStream(filepath);
const rl = readline.createInterface({
	input: fileStream,
	crlfDelay: Infinity
	});

// Note: we use the crlfDelay option to recognize all instances of CR LF
// ('\r\n') in input.txt as a single line break.

var lineNum = 0
for await (const line of rl) {
	lineNum += 1
	// Each line will be successively available here as 'line'
	if (func(line, lineNum)) {
		rl.close();      // close if true return value
		return;
		}
	}
} // forEachLine()
```
# ---------------------------------------------------------------------------

export forEachBlock = (filepath, func, regexp = /^-{16,}$/) ->

	lLines = []
	firstLineNum = 1
	earlyExit = false

	callback = (line, lineNum) ->
		if (line.match(regexp))
			if result = func(lLines.join('\n'), firstLineNum, line)
				if (result == true)
					earlyExit = true
					return true
				else if result?
					croak "forEachBlock() - callback returned '#{result}'"
			lLines = []
			firstLineNum = lineNum+1
		else
			lLines.push line
		return

	await forEachLine filepath, callback
	if ! earlyExit
		func(lLines.join('\n'), firstLineNum)
	return

# ---------------------------------------------------------------------------

export forEachSetOfBlocks = (filepath, func,
		block_regexp = /^-{16,}$/,
		set_regexp   = /^={16,}$/) ->

	lBlocks = []
	lLines = []
	firstLineNum = 1
	earlyExit = false

	callback = (line, lineNum) ->
		if (line.match(set_regexp))
			lBlocks.push(lLines.join('\n'))
			lLines = []
			if result = func(lBlocks, firstLineNum, line)
				if (result == true)
					earlyExit = true
					return true
				else if result?
					croak "forEachSetOfBlocks() - callback returned '#{result}'"
			lBlocks = []
			firstLineNum = lineNum+1
		else if (line.match(block_regexp))
			lBlocks.push(lLines.join('\n'))
			lLines = []
		else
			lLines.push line
		return

	await forEachLine filepath, callback
	if ! earlyExit
		lBlocks.push(lLines.join('\n'))
		func(lBlocks, firstLineNum)
	return
