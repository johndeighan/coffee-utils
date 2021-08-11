# utils.test.coffee

import {
	isTAML,
	taml,
	normalize,
	stringToArray,
	isEmpty,
	nonEmpty,
	isComment,
	words,
	escapeStr,
	truncateBlock,
	} from '../src/coffee_utils.js'
import {AvaTester} from '@jdeighan/ava-tester'

simple = new AvaTester()

# ---------------------------------------------------------------------------

simple.truthy 21, isEmpty('')
simple.truthy 22, isEmpty('  \t\t')
simple.truthy 23, isEmpty([])
simple.truthy 24, isEmpty({})

simple.truthy 26, nonEmpty('a')
simple.truthy 27, nonEmpty('.')
simple.truthy 28, nonEmpty([2])
simple.truthy 29, nonEmpty({width: 2})

simple.truthy 31, isComment("# a comment")
simple.truthy 32, isComment("#\ta comment")
simple.truthy 33, isComment("   # a comment")
simple.falsy  34, isComment("not much")
simple.falsy  35, isComment("#foreach x in lItems")

simple.truthy 37, isTAML("---\n- first\n- second")
simple.falsy  38, isTAML("x---\n")
simple.equal  39, taml("---\n- a\n- b"), ['a','b']

# ---------------------------------------------------------------------------

simple.equal 43, normalize("""
			line 1
			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 51, normalize("""
			line 1

			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 60, normalize("""

			line 1

			line 2


			"""), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 74, words('a b c'), ['a', 'b', 'c']
simple.equal 75, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

simple.equal 79, escapeStr("\t\tXXX\n"), "\\t\\tXXX\\n"

# ---------------------------------------------------------------------------

simple.equal 83, truncateBlock("""
			line 1
			line 2
			line 3
			line 4
			""", 2), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 95, stringToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 102, stringToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	]
