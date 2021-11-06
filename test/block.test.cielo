# block.test.cielo

import assert from 'assert'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {
	blockToArray, arrayToBlock, firstLine, remainingLines,
	normalizeBlock, truncateBlock,
	joinBlocks, forEachLine, forEachBlock, forEachSetOfBlocks,
	} from '@jdeighan/coffee-utils/block'

simple = new UnitTester()

# ---------------------------------------------------------------------------

simple.equal 16, blockToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	]

simple.equal 21, blockToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	]

simple.equal 26, blockToArray("abc\n\nxyz\n"), [
	'abc'
	''
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 34, arrayToBlock(['a','b','c']), "a\nb\nc\n"

# ---------------------------------------------------------------------------

simple.equal 38, firstLine("""
	#starbucks
	do this
	do that
	"""), '#starbucks'

# ---------------------------------------------------------------------------

simple.equal 46, remainingLines("""
	#starbucks
	do this
	do that
	"""), """
	do this
	do that
	"""

# ---------------------------------------------------------------------------

(() ->
	str = joinBlocks('import me', '', 'do this\ndo that')
	simple.equal 59, str, """
		import me
		do this
		do that
		"""
	)()

# ---------------------------------------------------------------------------

simple.equal 68, normalizeBlock("""
	line 1
	line 2
	"""), """
	line 1
	line 2
	""" + '\n'

simple.equal 76, normalizeBlock("""
	line 1

	line 2
	"""), """
	line 1
	line 2
	""" + '\n'

simple.equal 85, normalizeBlock("""

	line 1

	line 2


	"""), """
	line 1
	line 2
	""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 99, truncateBlock("""
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
	simple.equal 119, str, """
		import {say} from '@jdeighan/coffee-utils'
		<script>
			x = 42
		</script>
		"""
	)()

# ---------------------------------------------------------------------------

(() ->
	lImports = [
		"import {say} from '@jdeighan/coffee-utils'",
		]
	code = """
		if (x==42)
			log "line 2 in unit test"
		"""
	str = joinBlocks(lImports..., code)
	simple.equal 138, str, """

		import {say} from '@jdeighan/coffee-utils'
		if (x==42)
			log "line 2 in unit test"
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

	simple.equal 159, lLines, [
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

	simple.equal 180, lBlocks, [
		"abc\ndef",
		"abc\ndef\nghi",
		"abc\ndef\nghi\njkl",
		]
	)()
