# block.test.coffee

import {strict as assert} from 'assert'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	joinBlocks, forEachLine, forEachBlock, forEachSetOfBlocks,
	} from '@jdeighan/coffee-utils/block'

simple = new UnitTester()
simple.equal 11, 2+2, 4

# ---------------------------------------------------------------------------

(() ->
	str = joinBlocks('import me', '', 'do this\ndo that')
	simple.equal 17, str, """
			import me
			do this
			do that
			"""
	)()

# ---------------------------------------------------------------------------

(() ->
	lBlocks = [
		"import {say} from '@jdeighan/coffee-utils'",
		"",
		"<script>\n\tx = 42\n</script>",
		"",
		]
	str = joinBlocks(lBlocks...)
	simple.equal 34, str, """
			import {say} from '@jdeighan/coffee-utils'
			<script>
				x = 42
			</script>
			"""
	)()

# ---------------------------------------------------------------------------
# test forEachLine()

(() ->
	lLines = []

	callback = (line) ->
		lLines.push line
		return

	filepath = "c:/Users/johnd/coffee-utils/test/data/file2.txt"
	await forEachLine filepath, callback

	simple.equal 55, lLines, [
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

	simple.equal 76, lBlocks, [
			"abc\ndef",
			"abc\ndef\nghi",
			"abc\ndef\nghi\njkl",
			]
	)()
