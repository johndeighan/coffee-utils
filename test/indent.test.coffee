# indent.test.coffee

import {strict as assert} from 'assert'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {isInteger} from '@jdeighan/coffee-utils'
import {
	indentLevel, indentation, undented, splitLine,
	indented, tabify, untabify,
	} from '@jdeighan/coffee-utils/indent'

simple = new UnitTester()

# ---------------------------------------------------------------------------

simple.equal 20, indentLevel("abc"), 0
simple.equal 21, indentLevel("\tabc"), 1
simple.equal 22, indentLevel("\t\tabc"), 2

# ---------------------------------------------------------------------------

simple.equal 26, indentation(0), ''
simple.equal 27, indentation(1), "\t"
simple.equal 28, indentation(2), "\t\t"

# ---------------------------------------------------------------------------

simple.equal 32, undented("abc"), "abc"
simple.equal 33, undented("\tabc"), "abc"
simple.equal 34, undented("\t\tabc"), "abc"
simple.equal 35, undented("\t\tabc", 0), "\t\tabc"
simple.equal 36, undented("\t\tabc", 1), "\tabc"
simple.equal 37, undented("\t\tabc", 2), "abc"

# ---------------------------------------------------------------------------

simple.equal 53, undented("\t\tfirst\n\t\tsecond\n\t\t\tthird\n"),
		"first\nsecond\n\tthird\n",

# ---------------------------------------------------------------------------

simple.equal 58, splitLine("abc"), [0, "abc"]
simple.equal 59, splitLine("\tabc"), [1, "abc"]
simple.equal 60, splitLine("\t\tabc"), [2, "abc"]
simple.equal 45, splitLine("\t\t\t"), [0, ""]

# ---------------------------------------------------------------------------

simple.equal 64, indented("abc", 0), "abc"
simple.equal 65, indented("abc", 1), "\tabc"
simple.equal 66, indented("abc", 2), "\t\tabc"

# --- empty lines, indented, should just be empty lines
simple.equal 54, indented("abc\n\ndef", 2), "\t\tabc\n\n\t\tdef"

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	simple.equal 73, tabify("""
			first line
			#{prefix}second line
			#{prefix}#{prefix}third line
			""", 3), """
			first line
			\tsecond line
			\t\tthird line
			"""
	)()

# ---------------------------------------------------------------------------
# you don't need to tell it number of spaces

(() ->
	prefix = '   '    # 3 spaces

	simple.equal 90, tabify("""
			first line
			#{prefix}second line
			#{prefix}#{prefix}third line
			"""), """
			first line
			\tsecond line
			\t\tthird line
			"""
	)()

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	simple.equal 106, untabify("""
			first line
			\tsecond line
			\t\tthird line
			""", 3), """
			first line
			#{prefix}second line
			#{prefix}#{prefix}third line
			"""
	)()

# ---------------------------------------------------------------------------

simple.equal 112, indented("export name = undef", 1), "\texport name = undef"
simple.equal 113, indented("export name = undef", 2), "\t\texport name = undef"

# ---------------------------------------------------------------------------
# make sure indentLevel() works for blocks

simple.equal 109, indentLevel("\t\tabc\n\t\tdef\n\t\t\tghi"), 2

