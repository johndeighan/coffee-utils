# utils.test.coffee

import {AvaTester} from '@jdeighan/ava-tester'
import {
	isTAML, taml, normalize, stringToArray, isEmpty, ltrunc, rtrunc,
	nonEmpty, isComment, words, escapeStr, truncateBlock,
	} from '@jdeighan/coffee-utils'

simple = new AvaTester()

# ---------------------------------------------------------------------------

simple.truthy 13, isEmpty('')
simple.truthy 14, isEmpty('  \t\t')
simple.truthy 15, isEmpty([])
simple.truthy 16, isEmpty({})

simple.truthy 18, nonEmpty('a')
simple.truthy 10, nonEmpty('.')
simple.truthy 20, nonEmpty([2])
simple.truthy 21, nonEmpty({width: 2})

simple.truthy 23, isComment("# a comment")
simple.truthy 24, isComment("#\ta comment")
simple.truthy 25, isComment("   # a comment")
simple.falsy  26, isComment("not much")
simple.falsy  27, isComment("#foreach x in lItems")

simple.truthy 29, isTAML("---\n- first\n- second")
simple.falsy  30, isTAML("x---\n")
simple.equal  31, taml("---\n- a\n- b"), ['a','b']

# ---------------------------------------------------------------------------

simple.equal 35, normalize("""
			line 1
			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 43, normalize("""
			line 1

			line 2
			"""), """
			line 1
			line 2
			""" + '\n'

simple.equal 52, normalize("""

			line 1

			line 2


			"""), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 66, words('a b c'), ['a', 'b', 'c']
simple.equal 67, words('  a   b   c  '), ['a', 'b', 'c']

# ---------------------------------------------------------------------------

simple.equal 71, escapeStr("\t\tXXX\n"), "\\t\\tXXX\\n"

# ---------------------------------------------------------------------------

simple.equal 75, truncateBlock("""
			line 1
			line 2
			line 3
			line 4
			""", 2), """
			line 1
			line 2
			""" + '\n'

# ---------------------------------------------------------------------------

simple.equal 87, stringToArray("abc\nxyz\n"), [
	'abc'
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 94, stringToArray("abc\nxyz\n\n\n\n"), [
	'abc'
	'xyz'
	]

# ---------------------------------------------------------------------------

simple.equal 101, rtrunc('/user/lib/.env', 5), '/user/lib'
simple.equal 102, ltrunc('abcdefg', 3), 'defg'
