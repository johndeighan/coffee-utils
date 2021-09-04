# temp.coffee

import {say, undef, sep_eq} from '@jdeighan/coffee-utils'
import {
	forEachLine, forEachBlock, forEachSetOfBlocks,
	} from '@jdeighan/coffee-utils/block'

# ---------------------------------------------------------------------------

(() ->
	filepath = "c:/Users/johnd/coffee-utils/test/data/file2.txt"

	callback = (line, lineNum) ->
		console.log "[#{lineNum}] '#{line}'"
		return

	await forEachLine filepath, callback
	say sep_eq
	)

# ---------------------------------------------------------------------------

(() ->
	filepath = "c:/Users/johnd/coffee-utils/test/data/file3.txt"

	callback = (block, lineNum) ->
		console.log "[#{lineNum}] ----------------"
		console.log block
		return

	await forEachBlock filepath, callback
	say sep_eq
	)

# ---------------------------------------------------------------------------

(() ->
	filepath = "c:/Users/johnd/coffee-utils/test/data/file4.txt"

	callback = (lBlocks, lineNum) ->
		console.log "[#{lineNum}] ================"
		for block in lBlocks
			console.log block
			console.log '-'.repeat(8)
		return

	await forEachSetOfBlocks filepath, callback
	say sep_eq
	)()

# ---------------------------------------------------------------------------

