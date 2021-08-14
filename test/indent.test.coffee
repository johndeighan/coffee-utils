# indent.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'
import {
	indentLevel,
	indentation,
	undentedStr,
	undentedBlock,
	splitLine,
	indentedStr,
	indentedBlock,
	tabify,
	untabify,
	} from '@jdeighan/coffee-utils/indent'

tester = new AvaTester()

# ---------------------------------------------------------------------------

tester.equal 20, indentLevel("abc"), 0
tester.equal 21, indentLevel("\tabc"), 1
tester.equal 22, indentLevel("\t\tabc"), 2

# ---------------------------------------------------------------------------

tester.equal 26, indentation(0), ''
tester.equal 27, indentation(1), "\t"
tester.equal 28, indentation(2), "\t\t"

# ---------------------------------------------------------------------------

tester.equal 32, undentedStr("abc"), "abc"
tester.equal 33, undentedStr("\tabc"), "abc"
tester.equal 34, undentedStr("\t\tabc"), "abc"
tester.equal 35, undentedStr("\t\tabc", 0), "\t\tabc"
tester.equal 36, undentedStr("\t\tabc", 1), "\tabc"
tester.equal 37, undentedStr("\t\tabc", 2), "abc"

# ---------------------------------------------------------------------------

tester.equal 41, undentedBlock([
		"\t\tfirst",
		"\t\tsecond",
		"\t\t\tthird",
		]), """
		first
		second
			third
		""" + '\n'

# ---------------------------------------------------------------------------

tester.equal 53, undentedBlock("\t\tfirst\n\t\tsecond\n\t\t\tthird\n"),
		"first\nsecond\n\tthird\n",

# ---------------------------------------------------------------------------

tester.equal 58, splitLine("abc"), [0, "abc"]
tester.equal 59, splitLine("\tabc"), [1, "abc"]
tester.equal 60, splitLine("\t\tabc"), [2, "abc"]

# ---------------------------------------------------------------------------

tester.equal 64, indentedStr("abc", 0), "abc"
tester.equal 65, indentedStr("abc", 0), "abc"
tester.equal 66, indentedStr("abc", 0), "abc"

# ---------------------------------------------------------------------------

(() ->
	prefix = '   '    # 3 spaces

	tester.equal 73, tabify("""
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

	tester.equal 90, tabify("""
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

	tester.equal 106, untabify("""
			first line
			\tsecond line
			\t\tthird line
			""", 3), """
			first line
			#{prefix}second line
			#{prefix}#{prefix}third line
			"""
	)()
