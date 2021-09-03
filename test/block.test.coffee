# block.test.coffee

import {strict as assert} from 'assert'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	forEachLine, forEachBlock, forEachSetOfBlocks,
	} from '@jdeighan/coffee-utils/block'

simple = new UnitTester()
simple.equal 11, 2+2, 4

# ---------------------------------------------------------------------------
# test forEachLine()

(() ->
	lLines = []

	callback = (line) ->
		lLines.push line
		return

	filepath = "c:/Users/johnd/coffee-utils/test/data/file2.txt"
	await forEachLine filepath, callback

	simple.equal 26, lLines, [
			"abc",
			"def",
			"ghi",
			"jkl",
			]
	)()

# ---------------------------------------------------------------------------
# test forEachBlock()

(() ->
	lBlocks = []

	callback = (block) ->
		lBlocks.push block
		return

	filepath = "c:/Users/johnd/coffee-utils/test/data/file3.txt"
	await forEachBlock filepath, callback

	simple.equal 20, lBlocks, [
			"abc\ndef",
			"abc\ndef\nghi",
			"abc\ndef\nghi\njkl",
			]
	)()
