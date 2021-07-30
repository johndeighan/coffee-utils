# indent.test.coffee

import {
	indentLevel,
	indentation,
	undentedStr,
	undentedBlock,
	splitLine,
	indentedStr,
	indentedBlock,
	} from '../src/indent_utils.js'
import {AvaTester} from '@jdeighan/ava-tester'

tester = new AvaTester()

# ---------------------------------------------------------------------------

tester.equal 19, indentLevel("abc"), 0
tester.equal 20, indentLevel("\tabc"), 1
tester.equal 21, indentLevel("\t\tabc"), 2

# ---------------------------------------------------------------------------

tester.equal 25, indentation(0), ''
tester.equal 26, indentation(1), "\t"
tester.equal 27, indentation(2), "\t\t"

# ---------------------------------------------------------------------------

tester.equal 31, undentedStr("abc"), "abc"
tester.equal 32, undentedStr("\tabc"), "abc"
tester.equal 33, undentedStr("\t\tabc"), "abc"
tester.equal 34, undentedStr("\t\tabc", 0), "\t\tabc"
tester.equal 35, undentedStr("\t\tabc", 1), "\tabc"
tester.equal 36, undentedStr("\t\tabc", 2), "abc"

# ---------------------------------------------------------------------------

tester.equal 40, undentedBlock([
		"\t\tfirst",
		"\t\tsecond",
		"\t\t\tthird",
		]), """
		first
		second
			third
		""" + '\n'

# ---------------------------------------------------------------------------

tester.equal 52, undentedBlock("\t\tfirst\n\t\tsecond\n\t\t\tthird\n"),
		"first\nsecond\n\tthird\n",

# ---------------------------------------------------------------------------

tester.equal 57, splitLine("abc"), [0, "abc"]
tester.equal 58, splitLine("\tabc"), [1, "abc"]
tester.equal 59, splitLine("\t\tabc"), [2, "abc"]

# ---------------------------------------------------------------------------

tester.equal 63, indentedStr("abc", 0), "abc"
tester.equal 64, indentedStr("abc", 0), "abc"
tester.equal 65, indentedStr("abc", 0), "abc"

# ---------------------------------------------------------------------------
