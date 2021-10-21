# block_utils.coffee

import fs from 'fs'
import readline from 'readline'

import {
	assert, isEmpty, isString, nonEmpty, error, isComment, rtrim,
	} from '@jdeighan/coffee-utils'
import {log} from '@jdeighan/coffee-utils/log'

# ---------------------------------------------------------------------------
#   blockToArray - split a block into lines

export blockToArray = (block) ->

	if isEmpty(block)
		return []
	else
		lLines = block.split(/\r?\n/)

		# --- remove trailing empty lines
		len = lLines.length
		while (len > 0) && isEmpty(lLines[len-1])
			lLines.pop()
			len -= 1
		return lLines

# ---------------------------------------------------------------------------
#   arrayToBlock - block will have no trailing whitespace

export arrayToBlock = (lLines) ->

	if lLines.length == 0
		return ''
	else
		return rtrim(lLines.join('\n'))

# ---------------------------------------------------------------------------

export firstLine = (block) ->

	assert isString(block), "firstLine(): string expected"
	pos = block.indexOf('\n')
	if (pos == -1)
		return block
	else
		return block.substring(0, pos)

# ---------------------------------------------------------------------------

export remainingLines = (block) ->

	assert isString(block), "remainingLines(): string expected"
	pos = block.indexOf('\n')
	if (pos == -1)
		return ''
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
	for block in lBlocks
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
	if (! isComment(line) && func(line, lineNum)) {
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
					error "forEachBlock() - callback returned '#{result}'"
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
					error "forEachSetOfBlocks() - callback returned '#{result}'"
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
