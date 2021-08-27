# indent.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'
import {
	indentLevel, indentation, undentedStr, undentedBlock, splitLine,
	indented, indentedStr, indentedBlock, tabify, untabify,
	} from '@jdeighan/coffee-utils/indent'

simple = new AvaTester()

# ---------------------------------------------------------------------------

simple.equal 20, indentLevel("abc"), 0
simple.equal 21, indentLevel("\tabc"), 1
simple.equal 22, indentLevel("\t\tabc"), 2

# ---------------------------------------------------------------------------

simple.equal 26, indentation(0), ''
simple.equal 27, indentation(1), "\t"
simple.equal 28, indentation(2), "\t\t"

# ---------------------------------------------------------------------------

simple.equal 32, undentedStr("abc"), "abc"
simple.equal 33, undentedStr("\tabc"), "abc"
simple.equal 34, undentedStr("\t\tabc"), "abc"
simple.equal 35, undentedStr("\t\tabc", 0), "\t\tabc"
simple.equal 36, undentedStr("\t\tabc", 1), "\tabc"
simple.equal 37, undentedStr("\t\tabc", 2), "abc"

# ---------------------------------------------------------------------------

simple.equal 41, undentedBlock([
		"\t\tfirst",
		"\t\tsecond",
		"\t\t\tthird",
		]), """
		first
		second
			third
		""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 53, undentedBlock("\t\tfirst\n\t\tsecond\n\t\t\tthird\n"),
		"first\nsecond\n\tthird\n",

# ---------------------------------------------------------------------------

simple.equal 58, splitLine("abc"), [0, "abc"]
simple.equal 59, splitLine("\tabc"), [1, "abc"]
simple.equal 60, splitLine("\t\tabc"), [2, "abc"]

# ---------------------------------------------------------------------------

simple.equal 64, indentedStr("abc", 0), "abc"
simple.equal 65, indentedStr("abc", 0), "abc"
simple.equal 66, indentedStr("abc", 0), "abc"

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

simple.equal 112, indentedStr("export name = undef", 1), "\texport name = undef"
simple.equal 113, indentedBlock("export name = undef", 1), "\texport name = undef"
simple.equal 114, indented("export name = undef", 1), "\texport name = undef"
simple.equal 115, indented("export name = undef", 2), "\t\texport name = undef"
