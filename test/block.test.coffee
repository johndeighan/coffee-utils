# block.test.coffee

import {strict as assert} from 'assert'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	blockToArray, arrayToBlock, normalizeBlock, truncateBlock,
	joinBlocks, forEachLine, forEachBlock, forEachSetOfBlocks,
	} from '@jdeighan/coffee-utils/block'

simple = new UnitTester()
simple.equal 11, 2+2, 4

# ---------------------------------------------------------------------------

simple.equal 108, blockToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	]

simple.equal 113, blockToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	]

simple.equal 118, blockToArray("abc\n\nxyz\n"), [
	'abc'
	''
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 126, arrayToBlock(['a','b','c']), "a\nb\nc\n"

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

simple.equal 49, normalizeBlock("""
			line 1
			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 57, normalizeBlock("""
			line 1

			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 66, normalizeBlock("""

			line 1

			line 2


			"""), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 96, truncateBlock("""
			line 1
			line 2
			line 3
			line 4
			""", 2), """
			line 1
			line 2
			""" + '\n'

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
