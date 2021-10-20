# indent.test.coffee

import assert from 'assert'

import {UnitTester} from '@jdeighan/coffee-utils/test'
import {isInteger} from '@jdeighan/coffee-utils'
import {
	indentLevel, indentation, undented, splitLine,
	indented, tabify, untabify,
	} from '@jdeighan/coffee-utils/indent'

simple = new UnitTester()

# ---------------------------------------------------------------------------

simple.equal 16, indentLevel("abc"), 0
simple.equal 17, indentLevel("\tabc"), 1
simple.equal 18, indentLevel("\t\tabc"), 2

# ---------------------------------------------------------------------------

simple.equal 22, indentation(0), ''
simple.equal 23, indentation(1), "\t"
simple.equal 24, indentation(2), "\t\t"

# ---------------------------------------------------------------------------

simple.equal 28, undented("abc"), "abc"
simple.equal 29, undented("\tabc"), "abc"
simple.equal 30, undented("\t\tabc"), "abc"
simple.equal 31, undented("\t\tabc", 0), "\t\tabc"
simple.equal 32, undented("\t\tabc", 1), "\tabc"
simple.equal 33, undented("\t\tabc", 2), "abc"

# ---------------------------------------------------------------------------

simple.equal 37, undented("\t\tfirst\n\t\tsecond\n\t\t\tthird\n"),
		"first\nsecond\n\tthird\n",

# ---------------------------------------------------------------------------

simple.equal 42, splitLine("abc"), [0, "abc"]
simple.equal 43, splitLine("\tabc"), [1, "abc"]
simple.equal 44, splitLine("\t\tabc"), [2, "abc"]
simple.equal 45, splitLine("\t\t\t"), [0, ""]

# ---------------------------------------------------------------------------

simple.equal 49, indented("abc", 0), "abc"
simple.equal 50, indented("abc", 1), "\tabc"
simple.equal 51, indented("abc", 2), "\t\tabc"

# --- empty lines, indented, should just be empty lines
simple.equal 54, indented("abc\n\ndef", 2), "\t\tabc\n\n\t\tdef"

(() ->
	str = "main\n\toverflow: auto\n\nnav\n\toverflow: auto"
	exp = "\tmain\n\t\toverflow: auto\n\n\tnav\n\t\toverflow: auto"
	simple.equal 59, indented(str, 1), exp
	)()

# --- indented also handles arrays, so test them, too

# --- empty lines, indented, should just be empty lines
simple.equal 65, indented(['abc','','def'], 2), '\t\tabc\n\n\t\tdef'

(() ->
	lLines = ['main','\toverflow: auto','','nav','\toverflow: auto']
	lExp   = '\tmain\n\t\toverflow: auto\n\n\tnav\n\t\toverflow: auto'
	simple.equal 70, indented(lLines, 1), lExp
	)()

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	simple.equal 78, tabify("""
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

	simple.equal 95, tabify("""
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

	simple.equal 111, untabify("""
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

simple.equal 124, indented("export name = undef", 1), "\texport name = undef"
simple.equal 125, indented("export name = undef", 2), "\t\texport name = undef"

# ---------------------------------------------------------------------------
# make sure indentLevel() works for blocks

simple.equal 130, indentLevel("\t\tabc\n\t\tdef\n\t\t\tghi"), 2
